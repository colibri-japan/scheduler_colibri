class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :destroy, :archive, :toggle_cancelled, :from_master_to_general, :terminate, :create_individual_appointments]
  before_action :set_planning
  before_action :set_corporation
  before_action :set_nurses, only: [:new, :edit]
  before_action :set_patients, only: [:new, :edit]

  # GET /recurring_appointments
  # GET /recurring_appointments.json
  def index
    puts params[:master]
    @recurring_appointments = @planning.recurring_appointments.where('(recurring_appointments.termination_date IS NULL) OR ( recurring_appointments.termination_date > ?)', params[:start].to_date.beginning_of_day).to_be_displayed.includes(:patient, :nurse)

    @recurring_appointments = @recurring_appointments.where(nurse_id: params[:nurse_id]) if params[:nurse_id].present? && params[:nurse_id] != 'undefined'
    @recurring_appointments = @recurring_appointments.where(patient_id: params[:patient_id]) if params[:patient_id].present? && params[:patient_id] != 'undefined'
    @recurring_appointments = @recurring_appointments.where(master: params[:master]) if params[:master].present? && params[:master] != 'undefined'

    patient_resource = params[:patient_resource].present?

    respond_to do |format|
      format.json {render json: @recurring_appointments.as_json(start_time: params[:start], end_time: params[:end], patient_resource: patient_resource).flatten!}
      format.js
    end

  end

  # GET /recurring_appointments/1
  # GET /recurring_appointments/1.json
  def show
  end

  # GET /recurring_appointments/new
  def new
    @recurring_appointment = RecurringAppointment.new
    @services = @corporation.cached_most_used_services_for_select
  end

  # GET /recurring_appointments/1/edit
  def edit
    @activities = PublicActivity::Activity.where(trackable_type: 'RecurringAppointment', trackable_id: @recurring_appointment.id).all
    @services = @corporation.cached_most_used_services_for_select
  end

  # POST /recurring_appointments
  # POST /recurring_appointments.json
  def create
    @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)

    if @recurring_appointment.save 
      @activity = @recurring_appointment.create_activity :create, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, new_nurse: @recurring_appointment.nurse.try(:name), new_patient: @recurring_appointment.patient.try(:name), new_anchor: @recurring_appointment.anchor, new_start: @recurring_appointment.starts_at, new_end: @recurring_appointment.ends_at
    end
  end

  # PATCH/PUT /recurring_appointments/1
  # PATCH/PUT /recurring_appointments/1.json
  def update    
    @recurring_appointment = RecurringAppointment.find(params[:id])
    set_previous_params
    redefine_anchor_if_editing_after_some_date
      
    if @recurring_appointment.update(recurring_appointment_params)
      @new_recurring_appointment = RecurringAppointment.where(original_id: @recurring_appointment.id, master: true).last if @recurring_appointment.master
      recalculate_bonus
      @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_nurse: @previous_nurse, previous_patient: @previous_patient, previous_start: @previous_start, previous_end: @previous_end, previous_anchor: @previous_anchor, previous_edit_requested: @previous_edit_requested, previous_title: @previous_title, new_title: @recurring_appointment.title, new_edit_requested: @recurring_appointment.edit_requested, new_start: @recurring_appointment.starts_at, new_end: @recurring_appointment.ends_at, new_anchor: @recurring_appointment.anchor, new_nurse: @recurring_appointment.nurse.try(:name), new_patient: @recurring_appointment.patient.try(:name)
    end
  end

  def terminate 
    @recurring_appointment.termination_date = params[:t_date].to_date.beginning_of_day
    if @recurring_appointment.save 
      cancel_appointments_after_termination
      recalculate_bonus
      @activity = @recurring_appointment.create_activity :terminate, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
    end
  end

  def archive
    @recurring_appointment.archive 
    @recurring_appointment.displayable = false

    if @recurring_appointment.save(validate: false)
      cancel_all_appointments
      @activity = @recurring_appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_anchor: @recurring_appointment.anchor, previous_start: @recurring_appointment.starts_at, previous_end: @recurring_appointment.ends_at, previous_nurse: @recurring_appointment.nurse.try(:name), previous_patient: @recurring_appointment.patient.try(:name)
      recalculate_bonus
    end                  
  end

  def create_individual_appointments
    CreateIndividualAppointmentsWorker.perform_async(@recurring_appointment.id, params[:option1][:year], params[:option1][:month], params[:option2][:year], params[:option2][:month], params[:option3][:year], params[:option3][:month], params[:option2IsSelected], params[:option3IsSelected])
    recalculate_bonus
  end


  # DELETE /recurring_appointments/1
  # DELETE /recurring_appointments/1.json
  def destroy
    @activity = @recurring_appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
    @recurring_appointment.delete
  end

  private

    def set_previous_params
      @previous_nurse = @recurring_appointment.nurse.try(:name)
      @previous_nurse_id = @recurring_appointment.nurse_id
      @previous_patient = @recurring_appointment.patient.try(:name)
      @previous_start = @recurring_appointment.starts_at
      @previous_end = @recurring_appointment.ends_at
      @previous_anchor = @recurring_appointment.anchor
      @previous_edit_requested = @recurring_appointment.edit_requested
      @previous_title = @recurring_appointment.title
    end

    def redefine_anchor_if_editing_after_some_date
      if recurring_appointment_params[:anchor].blank? && recurring_appointment_params[:editing_occurrences_after].present?
        @recurring_appointment.anchor = recurring_appointment_params[:editing_occurrences_after].to_date
      end
    end

    def set_recurring_appointment
      @recurring_appointment = RecurringAppointment.find(params[:id])
    end

    def set_nurses
      @nurses = @corporation.nurses.all.order_by_kana
    end

    def set_patients
      @patients = @corporation.cached_active_patients_ordered_by_kana
    end

    def set_planning
      @planning = Planning.find(params[:planning_id])
    end

    def cancel_appointments_after_termination
      appointment_ids = Appointment.where(recurring_appointment_id: @recurring_appointment.id).to_be_displayed.where('starts_at > ?', params[:t_date].to_date.beginning_of_day).ids 
      CancelAppointmentsWorker.perform_async(appointment_ids) if appointment_ids.present?
    end

    def cancel_all_appointments
      appointment_ids = Appointment.to_be_displayed.where(recurring_appointment_id: @recurring_appointment.id).ids 
      CancelAppointmentsWorker.perform_async(appointment_ids) if appointment_ids.present?
    end

    def recalculate_bonus
      if @recurring_appointment.editing_occurrences_after.present?
        year_and_months = [{year: @recurring_appointment.editing_occurrences_after.year, month: @recurring_appointment.editing_occurrences_after.month}]
      else
        year_and_months = Appointment.where(recurring_appointment_id: @recurring_appointment.id).to_be_displayed.pluck(:starts_at).map{|d| {year: d.year, month: d.month}}.uniq
      end

      year_and_months.each do |year_and_month|
        puts 'year and month '
        puts year_and_month
        puts 'nurse_id'
        puts @recurring_appointment.nurse_id
        puts @previous_nurse_id if @previous_nurse_id.present?
        RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(@recurring_appointment.nurse_id, year_and_month[:year], year_and_month[:month])
        RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(@previous_nurse_id, year_and_month[:year], year_and_month[:month]) if @previous_nurse_id.present?
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :end_day, :starts_at, :ends_at, :frequency, :nurse_id, :patient_id, :planning_id, :color, :description, :master, :duration, :editing_occurrences_after, :edit_requested, :cancelled, :service_id, :synchronize_appointments)
    end


end
