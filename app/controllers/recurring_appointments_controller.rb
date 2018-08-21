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
      @recurring_appointments = @planning.recurring_appointments.where(nurse_id: params[:nurse_id], displayable: true)
    elsif params[:patient_id].present?
      @recurring_appointments = @planning.recurring_appointments.where(patient_id: params[:patient_id], displayable: true)
    elsif params[:q] == 'master'
      @recurring_appointments = @planning.recurring_appointments.where(master: true).includes(:patient, :nurse)
    elsif params[:patient_name].present?
      @recurring_appointments = @planning.recurring_appointments.joins(:patient).where(patients: {name: params[:patient_name]})
    elsif params[:nurse_name].present?
      @recurring_appointments = @planning.recurring_appointments.joins(:nurse).where(nurses: {name: params[:nurse_name]})
    else
     @recurring_appointments = @planning.recurring_appointments.where(displayable: true).includes(:patient, :nurse)
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
    from_master_planning?
    set_appointments
  end

  # POST /recurring_appointments
  # POST /recurring_appointments.json
  def create
    @recurring_appointment = @planning.recurring_appointments.new(recurring_appointment_params)
    @recurring_appointment.master = false if !current_user.admin?
    params[:commit] == '編集リストへ追加' ?  @recurring_appointment.edit_requested = true : @recurring_appointment.edit_requested = false

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
    @original_recurring_appointment = RecurringAppointment.find(params[:id])

    @recurring_appointment = @original_recurring_appointment.dup

    @recurring_appointment.original_id = @original_recurring_appointment.id

    if params[:appointment].present?
      #drag
      #obtain original day using delta
      delta = params[:delta].to_i
      start_day = DateTime.parse(params[:appointment][:start])
      start_day = start_day.strftime('%Q').to_i

      original_day_milliseconds = (start_day - delta)
      original_day = Time.strptime(original_day_milliseconds.to_s, '%Q').utc
      original_day = [original_day.strftime("%Y-%m-%d").to_s]

      #obtain the occurrence that happends on the original day
      appointments = @original_recurring_appointment.appointments(@start_valid, @end_valid)
      appointments.map!{|e| e.to_s}
      appointment_to_delete = appointments & original_day

      if appointment_to_delete.present?

        #create a new one-time appointment happening that specific day with the right parameters

        @recurring_appointment.frequency = 2
        @recurring_appointment.start = params[:appointment][:start]
        @recurring_appointment.end = params[:appointment][:end]
        @recurring_appointment.anchor = params[:appointment][:start]
        @recurring_appointment.end_day = params[:appointment][:end]
        @recurring_appointment.master = false
        @recurring_appointment.nurse_id = params[:appointment][:nurse_id] if params[:appointment][:nurse_id].present?

        if @recurring_appointment.save
          @deleted_occurrence = DeletedOccurrence.create(deleted_day: appointment_to_delete[0], recurring_appointment_id: @original_recurring_appointment.id)
          @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_nurse: @original_recurring_appointment.nurse.name, previous_patient: @original_recurring_appointment.patient.name, previous_start: @original_recurring_appointment.start, previous_end: @original_recurring_appointment.end, previous_anchor: @original_recurring_appointment.anchor
        end

      end

    elsif recurring_appointment_params[:edited_occurrence].present? && recurring_appointment_params[:edited_occurrence] != "全繰り返し"
      #general case with one day edit

      edited_occurrence = Wareki::Date.parse(recurring_appointment_params[:edited_occurrence])
      edited_occurrence = edited_occurrence.strftime('%Y-%m-%d')
      deleted_occurrence = DeletedOccurrence.create(recurring_appointment_id: @original_recurring_appointment.id, deleted_day: edited_occurrence)

      @recurring_appointment.title = recurring_appointment_params[:title]
      @recurring_appointment.description = recurring_appointment_params[:description]
      @recurring_appointment.color = recurring_appointment_params[:color]
      @recurring_appointment.nurse_id = recurring_appointment_params[:nurse_id]
      @recurring_appointment.patient_id = recurring_appointment_params[:patient_id]
      @recurring_appointment.master = recurring_appointment_params[:master]
      @recurring_appointment.frequency = 2
      @recurring_appointment.anchor = edited_occurrence
      @recurring_appointment.end_day = edited_occurrence
      params[:commit] == '編集リストへ追加' ? @recurring_appointment.edit_requested = true : @recurring_appointment.edit_requested = false

      if @recurring_appointment.save
        @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_nurse: @original_recurring_appointment.nurse.try(:name), previous_patient: @original_recurring_appointment.patient.try(:name), previous_start: @original_recurring_appointment.start, previous_end: @original_recurring_appointment.end, previous_anchor: @original_recurring_appointment.anchor

      end

    else
      #general case   
      if recurring_appointment_params[:master] == '1' && @original_recurring_appointment.master == true
        @original_recurring_appointment.master = false
        @original_recurring_appointment.displayable = false
      else
        @original_recurring_appointment.displayable = false
        @recurring_appointment.master = false
      end

      params[:commit] == '編集リストへ追加' ?  @recurring_appointment.edit_requested = true : @recurring_appointment.edit_requested = false
      
      if @recurring_appointment.update(recurring_appointment_params)
        @original_recurring_appointment.save
        @activity = @recurring_appointment.create_activity :update, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id, previous_nurse: @original_recurring_appointment.nurse.try(:name), previous_patient: @original_recurring_appointment.patient.try(:name), previous_start: @original_recurring_appointment.start, previous_end: @original_recurring_appointment.end, previous_anchor: @original_recurring_appointment.anchor
      end
      
    end


  end


  # DELETE /recurring_appointments/1
  # DELETE /recurring_appointments/1.json
  def destroy
    parse_deleted_day
    handle_recurring_appointment

    if @recurring_appointment.save
      respond_to do |format|
        save_deleted_occurrences
        @activity = @recurring_appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id, nurse_id: @recurring_appointment.nurse_id, patient_id: @recurring_appointment.patient_id

        format.js
      end
    end
  end

  private
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
      params[:q] == 'master' ? @master = true : @master = false
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recurring_appointment_params
      params.require(:recurring_appointment).permit(:title, :anchor, :end_day, :start, :end, :frequency, :nurse_id, :patient_id, :planning_id, :color, :description, :master, :edited_occurrence)
    end

    # Methods for DESTROY

    def parse_deleted_day
      recurring_appointment_params[:edited_occurrence] == '全繰り返し' ? @deleted_day = '' : @deleted_day = Wareki::Date.parse(recurring_appointment_params[:edited_occurrence])
    end

    def handle_recurring_appointment
      if @deleted_day.blank?
        @recurring_appointment.master = false if recurring_appointment_params[:master] == "true"
        @recurring_appointment.deleted = true
        @recurring_appointment.displayable = false
        @recurring_appointment.deleted_at = Time.now
      end

    end


    def save_deleted_occurrences
      unless @deleted_day.blank?
        @deleted_occurrence = @recurring_appointment.deleted_occurrences.create(deleted_day: @deleted_day.strftime('%Y-%m-%d'))
        if recurring_appointment_params[:master] == "false" && @recurring_appointment.master == true
          new_appointment = @recurring_appointment.dup
          new_appointment.frequency = 2
          new_appointment.anchor = @deleted_day
          new_appointment.end_day = @deleted_day + new_appointment.duration
          new_appointment.edit_requested = false
          new_appointment.displayable = false
          new_appointment.original_id = @recurring_appointment.id

          new_appointment.save!
        end
      end
    end
end
