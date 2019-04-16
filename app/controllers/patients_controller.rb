class PatientsController < ApplicationController
  before_action :set_corporation
  before_action :set_patient, except: [:index, :create, :new]
  before_action :set_planning, only: [:show, :master, :payable]
  before_action :set_printing_option, only: [:show, :master]
  before_action :set_main_nurse, only: [:master, :show, :payable]
  before_action :set_caveats, only: [:new, :edit]

  def index
    if params[:start].present? && params[:end].present? && params[:master] == 'false' && params[:planning_id].to_i == @corporation.planning.id
      @patients = @corporation.patients.active.joins(:appointments).where(appointments: {displayable: true, master: false, planning_id: params[:planning_id], starts_at: params[:start].to_date.beginning_of_day..params[:end].to_date.beginning_of_day}).order_by_kana
    elsif params[:start].present? && params[:end].present? && params[:master] == 'true' && params[:planning_id].to_i == @corporation.planning.id
      recurring_appointments_that_occurs_in_range = RecurringAppointment.where(planning_id: params[:planning_id]).to_be_displayed.from_master.not_terminated_at(params[:start].to_date).occurs_in_range(params[:start].to_date.beginning_of_day..(params[:end].to_date - 1.day).beginning_of_day)
      @patients = @corporation.patients.active.where(id: recurring_appointments_that_occurs_in_range.map(&:patient_id)).order_by_kana
    else
      @patients = @corporation.patients.active.order_by_kana.group_by_kana
    end

    @planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
    
    if stale?(@patients)
      respond_to do |format|
        format.html
        format.json {render json: @patients.as_json}
      end
    end
  end

  def show
    authorize @patient, :is_employee?
    
    @patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
    fetch_nurses_grouped_by_team

    @recurring_appointments = RecurringAppointment.where(patient_id: @patient.id, planning_id: @planning.id, displayable: true)

    @nurses_with_services = Nurse.joins(:provided_services).select("nurses.*, sum(provided_services.service_duration) as sum_service_duration").where(provided_services: {patient_id: @patient.id}).where(displayable: true).group('nurses.id').order('sum_service_duration DESC')

  end

  def master
    authorize @planning, :is_employee?

    @patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
    fetch_nurses_grouped_by_team
  end

  def edit
    set_nurses
  end

  def toggle_active
    if @patient.update(active: !@patient.active, toggled_active_at: Time.now)
      CancelPatientAppointmentsWorker.perform_async(@patient.id)
      redirect_to patients_path, notice: '利用者のサービスが停止されました。'
    end
  end

  def new
    @patient = Patient.new
    set_nurses
  end

  def create
    @patient = Patient.new(patient_params)
    @patient.corporation_id = @corporation.id

    respond_to do |format|
      if @patient.save
        format.html { redirect_to patients_path, notice: '利用者様が登録されました' }
      else
        puts @patient.errors.full_messages
        format.html { redirect_to patients_path, alert: '利用者様の登録が失敗しました' }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_back(fallback_location: authenticated_root_path, notice: '利用者様の情報がアップデートされました') }
      else
        format.html { redirect_back(fallback_location: authenticated_root_path, alert: '利用者様の情報のアップデートが失敗しました') }
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

  def new_master_to_schedule
    authorize current_user, :has_admin_access?
  end

  def master_to_schedule
    authorize current_user, :has_admin_access?

    @planning = @corporation.planning
    CopyPatientPlanningFromMasterWorker.perform_async(@patient.id, params[:month], params[:year])

    redirect_to planning_patient_path(@planning, @patient), notice: "#{@patient.name}様のサービスの反映が始まりました。数秒後リフレッシュしてください"
  end

  def payable 
    authorize current_user, :has_access_to_provided_services?
    authorize @patient, :is_employee?

    set_month_and_year_params
    fetch_nurses_grouped_by_team
    fetch_patients_grouped_by_kana

    first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
    last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
    end_of_today_in_japan = (Time.current + 9.hours).end_of_day < last_day ? (Time.current + 9.hours).end_of_day : last_day

    @services_from_appointments = ProvidedService.not_archived.in_range(first_day..end_of_today_in_japan).from_appointments.includes(:appointment, :patient).where(patient_id: @patient.id, planning_id: @planning.id).order(service_date: 'asc')
  end

  private

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def set_planning 
    @planning = Planning.find(params[:planning_id])
  end

  def set_corporation
    @corporation = Corporation.cached_find(current_user.corporation_id)
  end

  def set_caveats
    @caveats = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {taggable_type: 'Patient', taggable_id: @corporation.patients.ids, context: 'caveats'})
  end

  def set_printing_option
    @printing_option = @corporation.printing_option
  end

  def set_nurses
    @nurses = @corporation.nurses.displayable.order_by_kana
  end

  def set_main_nurse 
    @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
  end
  
  def set_month_and_year_params
    @selected_year = params[:y].present? ? params[:y] : Date.today.year
    @selected_month = params[:m].present? ? params[:m] : Date.today.month
  end

  def set_teams_id_by_name
    @teams_id_by_name = @corporation.cached_team_id_by_name
  end

  def fetch_nurses_grouped_by_team
    if @corporation.teams.any?
      @grouped_nurses = @corporation.cached_displayable_nurses_grouped_by_team_name
      set_teams_id_by_name
    else
      @grouped_nurses = @corporation.cached_displayable_nurses_grouped_by_fulltimer
    end
  end

  def fetch_patients_grouped_by_kana
    @patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
  end

  def patient_params
    params.require(:patient).permit(:name, :kana, :phone_mail, :phone_number, :address, :gender, :description, :handicap_level, :kaigo_level, :nurse_id, :doctor_name, :care_manager_name, :date_of_contract, insurance_policy: [], caveat_list:[])
  end
end
