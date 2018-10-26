class PatientsController < ApplicationController
  before_action :set_corporation
  before_action :set_patient, only: [:show, :edit, :toggle_active, :update, :master, :destroy, :master_to_schedule]
  before_action :set_planning, only: [:show, :master, :master_to_schedule]

  def index
    if params[:start].present? && params[:end].present? && params[:master].present? && @corporation.plannings.ids.include?(params[:planning_id].to_i)
      start_time = params[:start].to_date.beginning_of_day
      end_time = params[:end].to_date.beginning_of_day

      @patients = @corporation.patients.joins(:appointments).where(appointments: {displayable: true, master: params[:master], planning_id: params[:planning_id], starts_at: start_time..end_time})
      @patients = @patients.where(active: true).order_by_kana
    else 
      @patients = @corporation.patients.where(active: true).order_by_kana
    end

  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
    authorize @patient, :is_employee?
    
    @patients = @corporation.patients.where(active: true).order_by_kana
    @last_patient = @corporation.patients.last
    @full_timers = @corporation.nurses.where(full_timer: true).order_by_kana
    @part_timers = @corporation.nurses.where(full_timer: false).order_by_kana
    @last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last
    @activities = PublicActivity::Activity.where(planning_id: @planning.id, patient_id: @patient.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)
    @recurring_appointments = RecurringAppointment.where(patient_id: @patient.id, planning_id: @planning.id, displayable: true)

    @nurses_with_services = Nurse.joins(:provided_services).select("nurses.*, sum(provided_services.service_duration) as sum_service_duration").where(provided_services: {patient_id: @patient.id}).where(displayable: true).group('nurses.id').order('sum_service_duration DESC')

    set_valid_range
  end

  def master
    authorize @planning, :is_employee?

    @patients = @corporation.patients.where(active: true).all.order_by_kana
    @full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    @part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana
    @last_patient = @patients.last
    @last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last
      
    set_valid_range
		@admin = current_user.admin.to_s
  end

  def edit
  end

  def toggle_active
    @patient.update!(active: !@patient.active, toggled_active_at: Time.now)

    redirect_to patients_path, notice: '利用者のサービスが停止されました。'
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)
    @patient.corporation_id = @corporation.id

    respond_to do |format|
      if @patient.save
        format.html { redirect_to patients_path, notice: '利用者がセーブされました' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_back fallback_location: root_path, notice: '利用者の情報がアップデートされました' }
      else
        format.html {render :edit}
      end
    end
  end

  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to patients_url, notice: '利用者が削除されました' }
      format.json { head :no_content }
      format.js
    end
  end

  def master_to_schedule
    authorize current_user, :is_admin?

    @patient.recurring_appointments.where(planning_id: @planning.id, master: false).delete_all 
    @patient.appointments.where(planning_id: @planning.id, master: false).delete_all 
    @patient.provided_services.where(planning_id: @planning.id).delete_all

    new_recurring_appointments = []
    new_appointments = []
    new_provided_services = []

    initial_recurring_appointments_count = @patient.recurring_appointments.valid.edit_not_requested.from_master.where(planning_id: @planning.id).count
    initial_appointments_count = @patient.appointments.from_master.valid.edit_not_requested.where(planning_id: @planning.id).count

    @patient.recurring_appointments.valid.edit_not_requested.from_master.where(planning_id: @planning.id).find_each do |recurring_appointment|
      new_recurring_appointment = recurring_appointment.dup 
			new_recurring_appointment.master = false 
			new_recurring_appointment.original_id = recurring_appointment.id
      new_recurring_appointment.skip_appointments_callbacks = true 
      
      new_recurring_appointments << new_recurring_appointment
    end

    if new_recurring_appointments.count == initial_recurring_appointments_count
      RecurringAppointment.import(new_recurring_appointments)
    end

    new_recurring_appointments.each do |recurring_appointment|
      Appointment.where(recurring_appointment_id: recurring_appointment.original_id).each do |appointment|
        new_appointment = appointment.dup 
        new_appointment.master = false
        new_appointment.recurring_appointment_id = recurring_appointment.id

        new_appointments << new_appointment 
      end
    end

    if initial_appointments_count == new_appointments.count 
      Appointment.import(new_appointments)
    end

    new_appointments.each do |appointment|
      provided_duration = appointment.ends_at - appointment.starts_at
		  is_provided =  Time.current + 9.hours > appointment.starts_at
      new_provided_service = ProvidedService.new(appointment_id: appointment.id, planning_id: appointment.planning_id, service_duration: provided_duration, nurse_id: appointment.nurse_id, patient_id: appointment.patient_id, deactivated: appointment.deactivated, provided: is_provided, temporary: false, title: appointment.title, hour_based_wage: @corporation.hour_based_payroll, service_date: appointment.starts_at, appointment_start: appointment.starts_at, appointment_end: appointment.ends_at)
      new_provided_service.run_callbacks(:save) { false }
      new_provided_services << new_provided_service
    end

    ProvidedService.import(new_provided_services)

    redirect_to planning_patient_path(@planning, @patient), notice: "#{@patient.name}様のサービスが全体へ反映されました"

  end



  private

  def set_patient
    @patient = Patient.find(params[:id])
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

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end

  def patient_params
    params.require(:patient).permit(:name, :kana, :phone_mail, :phone_number, :address, :gender, :description, caveat_list:[])
  end
end
