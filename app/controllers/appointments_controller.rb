class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :edit, :destroy]
  before_action :set_planning
  before_action :set_corporation


  # GET /appointments
  # GET /appointments.json
  def index
    if params[:nurse_id].present?
      @appointments = @planning.appointments.where(nurse_id: params[:nurse_id], displayable: true)
    elsif params[:patient_id].present?
      @appointments = @planning.appointments.where(patient_id: params[:patient_id], displayable: true)
    elsif params[:q] == 'master'
      @appointments = @planning.appointments.where(master: true).includes(:patient)
    else
     @appointments = @planning.appointments.where(displayable: true).includes(:patient)
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
    @old_appointment = Appointment.find(params[:id])
    @appointment = @old_appointment.dup
    @appointment.master = false
    @appointment.displayable = true
    @appointment.save

    respond_to do |format|
      if @appointment.update(appointment_params)
        @activity = @appointment.create_activity :update, owner: current_user, planning_id: @planning.id
        @old_appointment.update(displayable: false)
        format.html { redirect_to @appointment, notice: 'Appointment was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit }
        format.js
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.json
  def destroy
    save_id = @appointment.id
    @appointment.destroy
    respond_to do |format|
      @activity = @appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id
      format.html { redirect_to appointments_url, notice: 'Appointment was successfully destroyed.' }
      format.json { head :no_content }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def appointment_params
      params.require(:appointment).permit(:title, :description, :start, :end, :nurse_id, :patient_id, :planning_id)
    end
end
