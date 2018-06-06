class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :update, :destroy]
  before_action :set_planning

  # GET /recurring_appointments
  # GET /recurring_appointments.json
  def index
    @recurring_appointments = @planning.recurring_appointments.all
  end

  # GET /recurring_appointments/1
  # GET /recurring_appointments/1.json
  def show
  end

  # GET /recurring_appointments/new
  def new
    @recurring_appointment = RecurringAppointment.new
    @nurses = Nurse.all
    @patients = Patient.all
  end

  # GET /recurring_appointments/1/edit
  def edit
    @nurses = Nurse.all
    @patients = Patient.all
  end

  # POST /recurring_appointments
  # POST /recurring_appointments.json
  def create
    @recurring_appointment = @planning.recurring_appointments.create(recurring_appointment_params)

    respond_to do |format|
      if @recurring_appointment.save
        format.html { redirect_to @recurring_appointment, notice: 'Recurring appointment was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @recurring_appointment }
      else
        format.html { render :new }
        format.js
        format.json { render json: @recurring_appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recurring_appointments/1
  # PATCH/PUT /recurring_appointments/1.json
  def update
    if params[:appointment]
      @recurring_appointment.update(anchor: params[:appointment][:start])
    else
      @recurring_appointment.update(recurring_appointment_params)
    end
  end

  # DELETE /recurring_appointments/1
  # DELETE /recurring_appointments/1.json
  def destroy
    @recurring_appointment.destroy
    respond_to do |format|
      format.html { redirect_to recurring_appointments_url, notice: 'Recurring appointment was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recurring_appointment
      @recurring_appointment = RecurringAppointment.find(params[:id])
    end

    def set_planning
      @planning = Planning.find(params[:planning_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :start_time, :end_time, :frequency, :nurse_id, :patient_id, :planning_id)
    end
end
