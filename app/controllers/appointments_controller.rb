class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :destroy]
  before_action :set_planning
  before_action :set_corporation


  # GET /appointments
  # GET /appointments.json
  def index
    authorize @planning, :is_employee?

    if params[:nurse_id].present?
      @appointments = @planning.appointments.where(nurse_id: params[:nurse_id], displayable: true, master: false)
    elsif params[:patient_id].present?
      @appointments = @planning.appointments.where(patient_id: params[:patient_id], displayable: true, master: false)
    elsif params[:master] == 'true'
      @appointments = @planning.appointments.where(master: true).includes(:patient)
    else
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
    from_master_planning?
    
    @nurses = @corporation.nurses.all 
    @patients = @corporation.patients.all
    @recurring_appointment = @appointment.recurring_appointment if @appointment.recurring_appointment_id.present?
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
    @original_appointment = Appointment.find(params[:id])
    @appointment = @original_appointment.dup
    @appointment.original_id = @original_appointment.id
    @appointment.recurring_appointment_id = nil
    params[:commit] == '編集リストへ追加' ?  @appointment.edit_requested = true : @appointment.edit_requested = false

    puts appointment_params

    respond_to do |format|
      if @appointment.update(appointment_params)
        @activity = @appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id, previous_nurse: @original_appointment.nurse.try(:name), previous_patient: @original_appointment.patient.try(:name), previous_start: @original_appointment.start, previous_end: @original_appointment.end
        @original_appointment.update(displayable: false, deleted: true, deleted_at: Time.current)
        format.js
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.js
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    @appointment.update(displayable: false, deleted: true, deleted_at: Time.current, recurring_appointment_id: nil)
    respond_to do |format|
      @activity = @appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @appointment.nurse_id, patient_id: @appointment.patient_id
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
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
