class PatientsController < ApplicationController
  before_action :set_corporation
  before_action :set_patient, only: [:show, :edit, :toggle_active, :update, :master, :destroy, :master_to_schedule]
  before_action :set_planning, only: [:show, :master, :master_to_schedule]
  before_action :set_printing_option, only: [:show, :master]
  before_action :set_main_nurse, only: [:master, :show]

  def index
    if params[:start].present? && params[:end].present? && params[:master].present? && @corporation.plannings.ids.include?(params[:planning_id].to_i)
      start_time = params[:start].to_date.beginning_of_day
      end_time = params[:end].to_date.beginning_of_day

      @patients = @corporation.patients.joins(:appointments).where(appointments: {displayable: true, master: params[:master], planning_id: params[:planning_id], starts_at: start_time..end_time})
      @patients = @patients.active.order_by_kana
    else 
      @patients = @corporation.patients.active.order_by_kana
    end

  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
    authorize @patient, :is_employee?
    
    @patients = @corporation.patients.active.order_by_kana
    fetch_nurses_grouped_by_team

    @activities = PublicActivity::Activity.where(planning_id: @planning.id, patient_id: @patient.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)
    @recurring_appointments = RecurringAppointment.where(patient_id: @patient.id, planning_id: @planning.id, displayable: true)

    @nurses_with_services = Nurse.joins(:provided_services).select("nurses.*, sum(provided_services.service_duration) as sum_service_duration").where(provided_services: {patient_id: @patient.id}).where(displayable: true).group('nurses.id').order('sum_service_duration DESC')

    set_valid_range
  end

  def master
    authorize @planning, :is_employee?

    @patients = @corporation.patients.active.all.order_by_kana
    fetch_nurses_grouped_by_team
      
    set_valid_range
		@admin = current_user.has_admin_access?.to_s
  end

  def edit
  end

  def toggle_active
    if @patient.update(active: !@patient.active, toggled_active_at: Time.now)
      CancelPatientAppointmentsWorker.perform_async(@patient.id)
      redirect_to patients_path, notice: '利用者のサービスが停止されました。'
    end
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
    authorize current_user, :has_admin_access?

    CopyPatientPlanningFromMasterWorker.perform_async(@patient.id, @planning.id)

    redirect_to planning_patient_path(@planning, @patient), notice: "#{@patient.name}様のサービスの反映が始まりました。数秒後リフレッシュしてください"

  end



  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def set_planning 
    @planning = Planning.find(params[:planning_id])
  end

  def set_valid_range
    @start_valid = Date.new(@planning.business_year, @planning.business_month, 1).strftime("%Y-%m-%d")
  end

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end

  def set_printing_option
    @printing_option = @corporation.printing_option
  end

  def set_main_nurse 
    @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
  end

  def fetch_nurses_grouped_by_team
    @nurses = @corporation.nurses.displayable.order_by_kana
    if @corporation.teams.any?
      @grouped_nurses = @nurses.group_by {|nurse| nurse.team.try(:team_name) }
    else
      nurses_grouped_by_full_timer = @nurses.group_by {|nurse| nurse.full_timer }
      full_timers = nurses_grouped_by_full_timer[true] ||= []
      part_timers = nurses_grouped_by_full_timer[false] ||= []
      @grouped_nurses = {'正社員' => full_timers, '非正社員' => part_timers }
    end
  end

  def patient_params
    params.require(:patient).permit(:name, :kana, :phone_mail, :phone_number, :address, :gender, :description, caveat_list:[])
  end
end
