class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :destroy, :archive, :toggle_edit_requested]
  before_action :set_planning
  before_action :set_corporation


  # GET /appointments
  # GET /appointments.json
  def index
    authorize @planning, :is_employee?

    if params[:nurse_id].present? && params[:master] != 'true'
      puts 'nurse not master'
      @appointments = @planning.appointments.where(nurse_id: params[:nurse_id], displayable: true, master: false)
    elsif params[:nurse_id].present? && params[:master] == 'true'
      puts 'nurse master'
      @appointments = @planning.appointments.where(nurse_id: params[:nurse_id], displayable: true, master: true)   
    elsif params[:patient_id].present? && params[:master] != 'true'
      puts 'patient not master'
      @appointments = @planning.appointments.where(patient_id: params[:patient_id], displayable: true, master: false)
    elsif params[:patient_id].present? && params[:master] == 'true'
      puts 'patient master'
      @appointments = @planning.appointments.where(patient_id: params[:patient_id], displayable: true, master: true)
    elsif params[:master] == 'true' && params[:nurse_id].blank? && params[:patient_id].blank?
      puts 'master'
      @appointments = @planning.appointments.where(master: true).includes(:patient)
    else
      puts 'general'
     @appointments = @planning.appointments.where(displayable: true, master: false).includes(:patient, :nurse)
    end
  end

  # GET /appointments/1
  # GET /appointments/1.json
  def show
  end

  # GET /appointments/new
  def new
    @appointment = Appointment.new
    @nurses = @corporation.nurses.all 
    @patients = @corporation.patients.all
  end

  # GET /appointments/1/edit
  def edit  
    @nurses = @corporation.nurses.all 
    @patients = @corporation.patients.all
    @master = @appointment.master
    @activities = PublicActivity::Activity.where(trackable_type: 'Appointment', trackable_id: @appointment.id).all
    puts 'activities present'
    puts @activities.present?
    @recurring_appointment = RecurringAppointment.find(@appointment.recurring_appointment_id) if @appointment.recurring_appointment_id.present?
  end

  # POST /appointments
  # POST /appointments.json
  def create
    @appointment = @planning.appointments.new(appointment_params)

    respond_to do |format|
      if @appointment.save
        @activity = @appointment.create_activity :create, owner: current_user, planning_id: @planning.id
        format.html { redirect_to @appointment, notice: 'Appointment was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { render :new }
        format.js
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /appointments/1
  # PATCH/PUT /appointments/1.json
  def update
    @appointment = Appointment.find(params[:id])
    store_original_params
    @appointment.recurring_appointment_id = nil

    respond_to do |format|
      if @appointment.update(appointment_params)
        @activity = @appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse: @previous_nurse, previous_patient: @previous_patient, previous_start: @previous_start, previous_end: @previous_end
        format.js
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.js
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  def archive
    @appointment.update(displayable: false, deleted: true, deleted_at: Time.current, recurring_appointment_id: nil)
    @activity = @appointment.create_activity :archive, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id
  end

  def toggle_edit_requested
    puts @appointment.edit_requested
    @appointment.edit_requested = !@appointment.edit_requested

    puts @appointment.edit_requested

    if @appointment.save
      @activity = @appointment.create_activity :toggle_edit_requested, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_edit_requested: !@appointment.edit_requested
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    @activity = @appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id
    @appointment.delete
  end

  private
    # Use methods to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    def store_original_params
      @previous_patient = @appointment.patient.try(:name)
      @previous_start = @appointment.start
      @previous_end = @appointment.end
      @previous_nurse = @appointment.nurse.try(:name)
    end

    def set_corporation
      @corporation = Corporation.find(current_user.corporation_id)
    end

    def set_planning
      @planning = Planning.find(params[:planning_id])
    end

    def from_master_planning?
      params[:q] == 'master' ? @master = true : @master = false
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:title, :description, :start, :end, :nurse_id, :patient_id, :planning_id, :color, :edit_requested)
    end
end
