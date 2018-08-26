class RecurringAppointmentsController < ApplicationController
  before_action :set_recurring_appointment, only: [:show, :edit, :destroy]
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
      @recurring_appointments = @planning.recurring_appointments.where(nurse_id: params[:nurse_id], displayable: true, master: false)
    elsif params[:patient_id].present?
      @recurring_appointments = @planning.recurring_appointments.where(patient_id: params[:patient_id], displayable: true, master: false)
    elsif params[:master] == 'true'
      @recurring_appointments = @planning.recurring_appointments.where(master: true).includes(:patient, :nurse)
    elsif params[:patient_name].present?
      master = params[:master] == 'true' ? true : false
      @recurring_appointments = @planning.recurring_appointments.joins(:patient).where(patients: {name: params[:patient_name]}).where(displayable: true, master: master)
    elsif params[:nurse_name].present?
      master = params[:master] == 'true' ? true : false
      @recurring_appointments = @planning.recurring_appointments.joins(:nurse).where(nurses: {name: params[:nurse_name]}).where(displayable: true, master: master)
    else
     @recurring_appointments = @planning.recurring_appointments.where(displayable: true, master: false).includes(:patient, :nurse)
    end



    if params[:print] == 'true'
      @occurrence_appointments = {}
      @recurring_appointments = @recurring_appointments.where.not(description: [nil, ''])

      @recurring_appointments.each do |recurring_appointment|
        appointments = recurring_appointment.appointments(@start_valid, @end_valid)
        appointments.each do |appointment|
          date = DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.start.hour, recurring_appointment.start.min)
          @occurrence_appointments[date] = recurring_appointment
        end
      end

      @occurrence_appointments = @occurrence_appointments.sort.to_h
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

    set_appointments
  end

  # POST /recurring_appointments
  # POST /recurring_appointments.json
  def create
    @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)
    add_to_edit_requested?
    add_to_master?

    respond_to do |format|
      if @recurring_appointment.save
        @activity = @recurring_appointment.create_activity :create, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
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
    add_to_edit_requested?
    set_previous_params
      
    if @recurring_appointment.update(recurring_appointment_params)
      @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_nurse: @previous_nurse, previous_patient: @previous_patient, previous_start: @previous_start, previous_end: @previous_end, previous_anchor: @previous_anchor 
    end
  end


  # DELETE /recurring_appointments/1
  # DELETE /recurring_appointments/1.json
  def destroy
    if @recurring_appointment.update(displayable: false)
      @activity = @recurring_appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id
    end
  end



  private

    def set_previous_params
      @previous_nurse = @recurring_appointment.nurse.try(:name)
      @previous_patient = @recurring_appointment.patient.try(:name)
      @previous_start = @recurring_appointment.start
      @previous_end = @recurring_appointment.end
      @previous_anchor = @recurring_appointment.anchor
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
      @patients = @corporation.patients.all.order_by_kana
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

    def set_appointments
      appointments = @recurring_appointment.appointments(@start_valid, @end_valid)
      appointments.map! {|appointment| appointment.strftime('%Jf')}
      @appointments = ["全繰り返し"] + appointments
    end

    def from_master_planning?
      params[:master] == 'true' ? @master = true : @master = false
    end

    def add_to_master?
      params[:master]== 'true' ? @recurring_appointment.master = true : @recurring_appointment.master = false
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :end_day, :start, :end, :frequency, :nurse_id, :patient_id, :planning_id, :color, :description, :master, :edited_occurrence)
    end


    def add_to_edit_requested?
      params[:commit] == '編集リストへ追加' ?  @recurring_appointment.edit_requested = true : @recurring_appointment.edit_requested = false
    end


end
