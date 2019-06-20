class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :archive, :toggle_cancelled, :from_master_to_general, :terminate, :create_individual_appointments]
  before_action :set_planning
  before_action :set_corporation
  before_action :set_nurses, only: [:new, :edit]
  before_action :set_patients, only: [:new, :edit]


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

  def show
  end

  def new
    authorize current_user, :has_admin_access?
    
    @recurring_appointment = RecurringAppointment.new
    @services = @corporation.cached_most_used_services_for_select
  end
  
  def edit
    authorize current_user, :has_admin_access?
    
    @activities = PublicActivity::Activity.where(trackable_type: 'RecurringAppointment', trackable_id: @recurring_appointment.id).all
    @services = @corporation.cached_most_used_services_for_select
  end
  
  def create
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
    @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)
    
    if @recurring_appointment.save 
      @activity = @recurring_appointment.create_activity :create, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, new_nurse: @recurring_appointment.nurse.try(:name), new_patient: @recurring_appointment.patient.try(:name), new_anchor: @recurring_appointment.anchor, new_start: @recurring_appointment.starts_at, new_end: @recurring_appointment.ends_at
    end
  end
  
  def update    
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
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
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
    @termination_date = params[:t_date].to_date.beginning_of_day
    @recurring_appointment.termination_date = @termination_date
    if @recurring_appointment.save 
      cancel_appointments_after_termination
      recalculate_bonus
      @activity = @recurring_appointment.create_activity :terminate, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
    end
  end
  
  def archive
    authorize current_user, :has_admin_access?
    authorize @planning, :same_corporation_as_current_user?
    
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
  end

  private

    def set_previous_params
      @previous_nurse = @recurring_appointment.nurse.try(:name)
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
      @nurses = @corporation.nurses.displayable.order_by_kana
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
      if @new_recurring_appointment.present?
        year_and_months = [{year: @new_recurring_appointment.anchor.year, month: @new_recurring_appointment.anchor.month}]
      elsif @termination_date.present?
        year_and_months = [{year: @termination_date.year, month: @termination_date.month}]
      else
        year_and_months = Appointment.where(recurring_appointment_id: @recurring_appointment.id).to_be_displayed.pluck(:starts_at).map{|d| {year: d.year, month: d.month}}.uniq
      end

      year_and_months.each do |year_and_month|
        RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(@recurring_appointment.nurse_id, year_and_month[:year], year_and_month[:month])
        RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(@new_recurring_appointment.nurse_id, year_and_month[:year], year_and_month[:month]) if @new_recurring_appointment.present? && @new_recurring_appointment.nurse_id != @recurring_appointment.nurse_id
      end
    end

    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :end_day, :starts_at, :ends_at, :frequency, :nurse_id, :patient_id, :planning_id, :color, :description, :master, :duration, :editing_occurrences_after, :edit_requested, :cancelled, :service_id, :synchronize_appointments)
    end


end
