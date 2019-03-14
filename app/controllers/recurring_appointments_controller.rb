class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :destroy, :archive, :toggle_cancelled, :from_master_to_general, :terminate, :create_individual_appointments]
  before_action :set_planning
  before_action :set_corporation
  before_action :set_nurses, only: [:new, :edit]
  before_action :set_patients, only: [:new, :edit]

  # GET /recurring_appointments
  # GET /recurring_appointments.json
  def index
    @recurring_appointments = @planning.recurring_appointments.where('(recurring_appointments.termination_date IS NULL) OR ( recurring_appointments.termination_date > ?)', params[:start].to_date.beginning_of_day).to_be_displayed.includes(:patient, :nurse)

    @recurring_appointments = @recurring_appointments.where(nurse_id: params[:nurse_id]) if params[:nurse_id].present? && params[:nurse_id] != 'undefined'
    @recurring_appointments = @recurring_appointments.where(patient_id: params[:patient_id]) if params[:patient_id].present? && params[:patient_id] != 'undefined'
    @recurring_appointments = @recurring_appointments.where(master: params[:master]) if params[:master].present? && params[:master] != 'undefined'

    respond_to do |format|
      format.json
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
  end

  # GET /recurring_appointments/1/edit
  def edit
    @activities = PublicActivity::Activity.where(trackable_type: 'RecurringAppointment', trackable_id: @recurring_appointment.id).all
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
      
    if @recurring_appointment.update(recurring_appointment_params)
      @new_recurring_appointment = RecurringAppointment.where(original_id: @recurring_appointment.id, master: true).last if @recurring_appointment.master
      @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_nurse: @previous_nurse, previous_patient: @previous_patient, previous_start: @previous_start, previous_end: @previous_end, previous_anchor: @previous_anchor, previous_edit_requested: @previous_edit_requested, previous_title: @previous_title, new_title: @recurring_appointment.title, new_edit_requested: @recurring_appointment.edit_requested, new_start: @recurring_appointment.starts_at, new_end: @recurring_appointment.ends_at, new_anchor: @recurring_appointment.anchor, new_nurse: @recurring_appointment.nurse.try(:name), new_patient: @recurring_appointment.patient.try(:name)
    end
  end

  def toggle_edit_requested
    @recurring_appointment = RecurringAppointment.find(params[:id])
    if @recurring_appointment.update_attribute(edit_requested: !@recurring_appointment.edit_requested)
      @activity = @recurring_appointment.create_activity :toggle_edit_requested, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_edit_requested: !@recurring_appointment.edit_requested
    end
  end

  def toggle_cancelled
    @recurring_appointment.cancelled = !@recurring_appointment.cancelled

    if @recurring_appointment.save 
      @activity = @recurring_appointment.create_activity :toggle_cancelled, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_cancelled: !@recurring_appointment.cancelled
    end
  end

  def terminate 
    @recurring_appointment.termination_date = params[:t_date].to_date.beginning_of_day
    if @recurring_appointment.save 
      @activity = @recurring_appointment.create_activity :terminate, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
    end
  end

  def archive
    @recurring_appointment.archive 
    @recurring_appointment.displayable = false

    if @recurring_appointment.save(validate: false)
      @activity = @recurring_appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_anchor: @recurring_appointment.anchor, previous_start: @recurring_appointment.starts_at, previous_end: @recurring_appointment.ends_at, previous_nurse: @recurring_appointment.nurse.try(:name), previous_patient: @recurring_appointment.patient.try(:name)
    end                  
  end

  def create_individual_appointments
    CreateIndividualAppointmentsWorker.perform_async(@recurring_appointment.id, params[:option1][:year], params[:option1][:month], params[:option2][:year], params[:option2][:month], params[:option2IsSelected])
  end


  # DELETE /recurring_appointments/1
  # DELETE /recurring_appointments/1.json
  def destroy
    @activity = @recurring_appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
    @recurring_appointment.delete
  end

  # PATCH /recurring_appointments/1/from_master_to_general
  def from_master_to_general 
    @new_appointment = @recurring_appointment.dup
    @new_appointment.master = false 
    @new_appointment.original_id = false 

    @nurse= Nurse.find(@recurring_appointment.nurse_id)

    respond_to do |format|
      if @new_appointment.save 
        @activity = @new_appointment.create_activity :create, owner: current_user, planning_id: @planning.id, nurse_id: @new_appointment.nurse_id, patient_id: @new_appointment.patient_id , new_nurse: @new_appointment.nurse.try(:name), new_patient: @new_appointment.patient.try(:name), new_anchor: @new_appointment.anchor, new_start: @new_appointment.starts_at, new_end: @new_appointment.ends_at

        format.js
      else 
        format.js
      end
    end
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

    def set_recurring_appointment
      @recurring_appointment = RecurringAppointment.find(params[:id])
    end

    def set_corporation
      @corporation = Corporation.cached_find(current_user.corporation_id)
    end

    def set_nurses
      @nurses = @corporation.nurses.all.order_by_kana
    end

    def set_patients
      @patients = @corporation.patients.active.order_by_kana
    end


    def set_planning
      @planning = Planning.find(params[:planning_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :end_day, :starts_at, :ends_at, :frequency, :nurse_id, :patient_id, :planning_id, :color, :description, :master, :duration, :editing_occurrences_after, :edit_requested, :cancelled, :service_id, :synchronize_appointments)
    end


end
