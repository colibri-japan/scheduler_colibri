class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :destroy, :archive, :toggle_cancelled, :from_master_to_general]
  before_action :set_planning
  before_action :set_valid_range, only: [:new, :edit, :index, :update]
  before_action :set_corporation
  before_action :set_nurses, only: [:new, :edit]
  before_action :set_patients, only: [:new, :edit]

  # GET /recurring_appointments
  # GET /recurring_appointments.json
  def index
    if params[:nurse_id].present?
      @nurse = Nurse.find(params[:nurse_id])
      @recurring_appointments = @planning.recurring_appointments.where(nurse_id: params[:nurse_id], displayable: true, master: false).where.not(cancelled: true)
    elsif params[:patient_id].present?
      @recurring_appointments = @planning.recurring_appointments.where(patient_id: params[:patient_id], displayable: true, master: false).where.not(cancelled: true)
    elsif params[:master] == 'true'
      @recurring_appointments = @planning.recurring_appointments.where(master: true).where.not(cancelled: true).includes(:patient, :nurse)
    elsif params[:patient_name].present?
      master = params[:master] == 'true' ? true : false
      @recurring_appointments = @planning.recurring_appointments.joins(:patient).where(patients: {name: params[:patient_name]}).where(displayable: true, master: master).where.not(cancelled: true)
    elsif params[:nurse_name].present?
      master = params[:master] == 'true' ? true : false
      @recurring_appointments = @planning.recurring_appointments.joins(:nurse).where(nurses: {name: params[:nurse_name]}).where(displayable: true, master: master).where.not(cancelled: true)
    else
     @recurring_appointments = @planning.recurring_appointments.where(displayable: true, master: false).where.not(cancelled: true).includes(:patient, :nurse)
    end

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
    from_master_planning?
    @recurring_appointment = RecurringAppointment.new
  end

  # GET /recurring_appointments/1/edit
  def edit
    @master = @recurring_appointment.master
    @appointments = Appointment.where(recurring_appointment_id: @recurring_appointment.id, planning_id: @recurring_appointment.planning_id, master: @recurring_appointment.master, displayable: true).order(starts_at: 'asc')
    @appointments_after_first = @appointments.drop(1)
    @activities = PublicActivity::Activity.where(trackable_type: 'RecurringAppointment', trackable_id: @recurring_appointment.id).all
  end

  # POST /recurring_appointments
  # POST /recurring_appointments.json
  def create
    @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)
    add_to_master?

    respond_to do |format|
      if @recurring_appointment.save
        @activity = @recurring_appointment.create_activity :create, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, new_nurse: @recurring_appointment.nurse.try(:name), new_patient: @recurring_appointment.patient.try(:name), new_anchor: @recurring_appointment.anchor, new_start: @recurring_appointment.starts_at, new_end: @recurring_appointment.ends_at
        puts 'saved recurring appointment and activity, now fetching appointments'
        @appointments = Appointment.where(recurring_appointment_id: @recurring_appointment.id)
        format.js
        format.json { render :show, status: :created, location: @recurring_appointment }
      else
        format.js
        format.json { render json: @recurring_appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recurring_appointments/1
  # PATCH/PUT /recurring_appointments/1.json
  def update    
    @recurring_appointment = RecurringAppointment.find(params[:id])
    set_previous_params
    appointment_ids = Appointment.valid.where(recurring_appointment_id: @recurring_appointment.id).ids
      
    if @recurring_appointment.update(recurring_appointment_params)
      @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_nurse: @previous_nurse, previous_patient: @previous_patient, previous_start: @previous_start, previous_end: @previous_end, previous_anchor: @previous_anchor, previous_edit_requested: @previous_edit_requested, previous_title: @previous_title, new_title: @recurring_appointment.title, new_edit_requested: @recurring_appointment.edit_requested, new_start: @recurring_appointment.starts_at, new_end: @recurring_appointment.ends_at, new_anchor: @recurring_appointment.anchor, new_nurse: @recurring_appointment.nurse.try(:name), new_patient: @recurring_appointment.patient.try(:name)
      @appointments = Appointment.find(appointment_ids)
    end
  end

  def toggle_edit_requested
    @recurring_appointment = RecurringAppointment.find(params[:id])
    if @recurring_appointment.update_attribute(edit_requested: !@recurring_appointment.edit_requested)
      @activity = @recurring_appointment.create_activity :toggle_edit_requested, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_edit_requested: !@recurring_appointment.edit_requested
      @appointments = Appointment.where(recurring_appointment_id: @recurring_appointment.id, displayable: true)
    end
  end

  def toggle_cancelled
    @recurring_appointment.cancelled = !@recurring_appointment.cancelled
    @recurring_appointment.editing_occurrences_after = recurring_appointment_params[:editing_occurrences_after]

    if @recurring_appointment.save 
      @activity = @recurring_appointment.create_activity :toggle_cancelled, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_cancelled: !@recurring_appointment.cancelled
      @appointments = Appointment.where(recurring_appointment_id: @recurring_appointment.id, displayable: true)
    end
  end

  def archive
    appointment_ids = Appointment.where(recurring_appointment_id: @recurring_appointment.id).ids
    @recurring_appointment.archive 
    @recurring_appointment.editing_occurrences_after = recurring_appointment_params[:editing_occurrences_after]
    @recurring_appointment.displayable = false

    if @recurring_appointment.save(validate: false)
      @activity = @recurring_appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_anchor: @recurring_appointment.anchor, previous_start: @recurring_appointment.starts_at, previous_end: @recurring_appointment.ends_at, previous_nurse: @recurring_appointment.nurse.try(:name), previous_patient: @recurring_appointment.patient.try(:name)
      @appointments = Appointment.find(appointment_ids)
    end                  
  end


  # DELETE /recurring_appointments/1
  # DELETE /recurring_appointments/1.json
  def destroy
    @activity = @recurring_appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
    @appointments = Appointment.where(recurring_appointment_id: @recurring_appointment.id)
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
        format.html{ redirect_to planning_nurse_path(@planning, Nurse.find(@new_appointment.nurse_id)), notice: 'サービスがマスターから全体へ反映されました'}
      else 
        format.js
        format.html {redirect_to planning_master_path(@planning), notice: '反映にエラーが発生しました。'}
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
      @corporation = Corporation.find(current_user.corporation_id)
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

    def set_valid_range
      @start_valid = Date.new(@planning.business_year, @planning.business_month, 1).strftime("%Y-%m-%d")
      @end_valid = (Date.new(@planning.business_year, @planning.business_month, 1) + 1.month).strftime("%Y-%m-%d")
    end

    def from_master_planning?
      params[:master] == 'true' ? @master = true : @master = false
    end

    def add_to_master?
      params[:master]== 'true' ? @recurring_appointment.master = true : @recurring_appointment.master = false
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :end_day, :starts_at, :ends_at, :frequency, :nurse_id, :patient_id, :planning_id, :color, :description, :master, :duration, :editing_occurrences_after, :edit_requested, :service_id)
    end


end
