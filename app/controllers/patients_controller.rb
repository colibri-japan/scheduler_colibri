class PatientsController < ApplicationController
  before_action :set_corporation
  before_action :set_patient, only: [:show, :edit, :toggle_active, :update, :master, :destroy, :master_to_schedule]
  before_action :set_planning, only: [:show, :master, :master_to_schedule]

  def index
    if params[:start].present? && params[:end].present? && params[:master].present?
      start_time = params[:start].to_date.beginning_of_day
      end_time = params[:end].to_date.beginning_of_day

      @patients = @corporation.patients.joins(:appointments).where(appointments: {displayable: true, master: params[:master], start: start_time..end_time})
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
        format.html {redirect_to patients_path, notice: '利用者の情報がアップデートされました' }
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

    @patient.recurring_appointments.where(planning_id: @planning.id, master: false).destroy_all 

    @patient.recurring_appointments.where(planning_id: @planning.id, master: true, displayable: true, deactivated: false, deleted: false, edit_requested: false).find_each do |recurring_appointment|
      new_recurring_appointment = recurring_appointment.dup 
			new_recurring_appointment.master = false 
			new_recurring_appointment.original_id = nil 
			new_recurring_appointment.skip_appointments_callbacks = true 
      new_recurring_appointment.save!(validate: false) 
      
      Appointment.where(recurring_appointment_id: recurring_appointment.id).find_each do |appointment|
      	new_appointment = appointment.dup 
				new_appointment.master = false 
				new_appointment.original_id = nil 
				new_appointment.recurring_appointment_id = new_recurring_appointment.id 
				new_appointment.save!(validate: false)
      end
    end

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
    params.require(:patient).permit(:name, :kana, :phone_mail, :phone_number, :address)
  end
end
