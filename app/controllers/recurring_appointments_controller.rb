class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :destroy]
  before_action :set_planning
  before_action :set_valid_range, only: [:new, :edit]

  # GET /recurring_appointments
  # GET /recurring_appointments.json
  def index
     if params[:nurse_id].present?
       @recurring_appointments = @planning.recurring_appointments.where(nurse_id: params[:nurse_id], displayable: true)
     elsif params[:patient_id].present?
       @recurring_appointments = @planning.recurring_appointments.where(patient_id: params[:patient_id], displayable: true)
     elsif params[:q] == 'master'
       @recurring_appointments = @planning.recurring_appointments.where(master: true).includes(:patient)
     else
      @recurring_appointments = @planning.recurring_appointments.where(displayable: true).includes(:patient)
    end

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
    @master = true if params[:q] == 'master'
  end

  # GET /recurring_appointments/1/edit
  def edit
    @nurses = Nurse.all
    @patients = Patient.all
    @master = true if params[:q] == 'master'
  end

  # POST /recurring_appointments
  # POST /recurring_appointments.json
  def create
    if params[:q] == 'master'
      @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)
      @recurring_appointment.master = true

      respond_to do |format|
        if @recurring_appointment.save
          @activity = @recurring_appointment.create_activity :create, owner: current_user, planning_id: @planning.id
          format.js
          format.json { render :show, status: :created, location: @recurring_appointment }
        else
          format.js
          format.json { render json: @recurring_appointment.errors, status: :unprocessable_entity }
        end
      end

    else       
      @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)
      @recurring_appointment.master = false

      respond_to do |format|
        if @recurring_appointment.save
          @activity = @recurring_appointment.create_activity :create, owner: current_user, planning_id: @planning.id
          format.js
          format.json { render :show, status: :created, location: @recurring_appointment }
        else
          format.js
          format.json { render json: @recurring_appointment.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /recurring_appointments/1
  # PATCH/PUT /recurring_appointments/1.json
  def update
    if params[:q] == 'master'
      @recurring_appointment = RecurringAppointment.find(params[:id])
      @original_recurring_appointment = @recurring_appointment
      @recurring_appointment.update(recurring_appointment_params)
      @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id

    else
      @original_recurring_appointment = RecurringAppointment.find(params[:id])

      @recurring_appointment = @original_recurring_appointment.dup
      @recurring_appointment.master = false
      @recurring_appointment.displayable = true
      @recurring_appointment.original_id = @original_recurring_appointment.id

      @recurring_appointment.save


      if params[:appointment].present?
        @recurring_appointment.update(start: params[:appointment][:start], end: params[:appointment][:end], anchor: params[:appointment][:start])
        @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id

        @original_recurring_appointment.update(displayable: false)
      else
        @recurring_appointment.update(recurring_appointment_params)
        @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id

        @original_recurring_appointment.update(displayable: false)
      end
    end
  end


  # DELETE /recurring_appointments/1
  # DELETE /recurring_appointments/1.json
  def destroy
    @activity = @recurring_appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id
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

    def set_valid_range
      valid_month = @planning.business_month
      valid_year = @planning.business_year
      @start_valid = Date.new(valid_year, valid_month, 1).strftime("%Y-%m-%d")
      @end_valid = Date.new(valid_year, valid_month +1, 1).strftime("%Y-%m-%d")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :start, :end, :frequency, :nurse_id, :patient_id, :planning_id)
    end
end
