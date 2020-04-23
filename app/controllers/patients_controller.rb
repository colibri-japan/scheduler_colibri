class PatientsController < ApplicationController
  before_action :set_corporation
  before_action :set_patient, except: [:index, :create, :new, :search_by_kana_group]
  before_action :set_planning, only: [:show, :payable]
  before_action :set_printing_option, only: [:show]
  before_action :set_caveats, only: [:new, :edit]

  def index
    set_planning 

    if params[:start].present? && params[:end].present? && params[:resource_type] == 'appointments' && params[:planning_id].to_i == @planning.id
      @patients = @corporation.patients.active.joins(:appointments).where(appointments: {archived_at: nil, planning_id: params[:planning_id], starts_at: params[:start].to_date.beginning_of_day..params[:end].to_date.beginning_of_day}).order_by_kana
      @patients = @patients.where(team_id: [current_user.team_id, nil]) if @corporation.separate_patients_by_team && current_user.team_id.present?
    elsif params[:start].present? && params[:end].present? && params[:resource_type] == 'recurring_appointments' && params[:planning_id].to_i == @planning.id
      patient_ids_from_recurring_appointments = RecurringAppointment.where(planning_id: params[:planning_id]).not_archived.not_terminated_at(params[:start].to_date).occurs_in_range(params[:start].to_date.beginning_of_day..(params[:end].to_date - 1.day).beginning_of_day).pluck(:patient_id).uniq
      @patients = @corporation.patients.active.where(id: patient_ids_from_recurring_appointments).order_by_kana if @corporation.separate_patients_by_team && current_user.team_id.present?
      @patients = @patients.where(team_id: [current_user.team_id, nil])
    else
      # patients index page
      @user_team = current_user.team
      set_main_nurse
      if @corporation.separate_patients_by_team && @user_team.present?
        @active_patients_count = @corporation.patients.active.where(team_id: [@user_team.id, nil]).count
        @deactivated_patients = @corporation.patients.deactivated.where(team_id: [@user_team.id, nil]).order_by_kana
      else
        @active_patients_count = @corporation.patients.active.count
        @deactivated_patients = @corporation.cached_inactive_patients_ordered_by_kana
      end
    end
    
    respond_to do |format|
      format.html
      format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=\"一覧_#{Date.today.strftime('%Y年%-m月%-d日')}.xlsx\""}
      format.json {render json: @patients.as_json}
    end
  end

  def search_by_kana_group
    @kana = params[:kana_group]
    kana_query = query_by_kana_params(params[:kana_group])
    @patients = @corporation.patients.active.where(kana_query).order_by_kana
    @patients = @patients.where(team_id: [current_user.team_id, nil]) if @corporation.separate_patients_by_team && current_user.team_id.present?
  end

  def show
    authorize @patient, :same_corporation_as_current_user?

    @nurses_with_services = Nurse.joins(:appointments).select("nurses.*, sum(appointments.duration) as sum_appointments_duration").where(appointments: {patient_id: @patient.id, archived_at: nil, cancelled: false, edit_requested: false}).displayable.not_archived.group('nurses.id').order('sum_appointments_duration DESC')
    @care_manager = @patient.care_plans.last.try(:care_manager)

    respond_to do |format|
      format.js 
    end
  end

  def edit
    set_nurses
    set_care_managers
    set_teams

    @care_plans = @patient.care_plans.includes(:care_manager).order(created_at: :desc)

    respond_to do |format|
      format.js 
      format.js.phone
    end
  end

  def toggle_active
    @patient.toggle(:active)
    @patient.toggled_active_at = Time.now 

    if @patient.save(validate: false)
      if @patient.active 
        redirect_to patients_path, notice: "#{@patient.try(:name)}様をサービス実施中に戻しました。"
      else
        CancelPatientAppointmentsWorker.perform_async(@patient.id)
        redirect_to patients_path, notice: "#{@patient.try(:name)}様のサービスが停止されました。"
      end
    end
  end

  def new
    @patient = Patient.new
    @patient.care_plans.build

    set_nurses
    set_care_managers
    set_teams

    respond_to do |format|
      format.js 
      format.js.phone
    end
  end

  def create
    params = patient_params
    params = convert_wareki_dates(params) 

    @patient = Patient.new(params)
    @patient.corporation_id = @corporation.id

    respond_to do |format|
      if @patient.save
        format.html { redirect_to patients_path, notice: "#{@patient.try(:name)}様が登録されました" }
      else
        format.html { redirect_to patients_path, alert: '登録が失敗しました' }
      end
    end
  end
  
  def update
    params = patient_params
    params = convert_wareki_dates(params)

    respond_to do |format|
      if @patient.update(params)
        format.js
        format.html { redirect_back(fallback_location: current_user_home_path, notice: '利用者様の情報がアップデートされました') }
      else
        format.js
        format.html { redirect_back(fallback_location: current_user_home_path, alert: '利用者様の情報のアップデートが失敗しました') }
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

  def teikyohyo
    authorize current_user, :has_access_to_salary_line_items?
    authorize @patient, :same_corporation_as_current_user?

    @first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
    @last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
    @end_of_today_in_japan = (Time.current + 9.hours).end_of_day < @last_day ? (Time.current + 9.hours).end_of_day : @last_day
  
    @appointments_till_today = @patient.appointments.not_archived.in_range(@first_day..@end_of_today_in_japan).includes(:nurse).order(starts_at: 'asc')

    @invoicing_summary = @patient.invoicing_summary(@first_day..@end_of_today_in_japan)

    @cancelled_but_invoiceable_appointments = @appointments_till_today.where(cancelled: true).where.not(total_invoiced: [0, nil])
    @care_plan = @patient.care_plans.valid_at(@first_day).first
    @previous_care_plan = @patient.care_plans.valid_at(@first_day - 1.month)

    respond_to do |format|
      format.html 
      format.pdf do
        render pdf: "#{@patient.name}様_提供表_#{@first_day.j_full_year}#{@first_day.strftime('%-m月')}分",
        page_size: 'A4',
        layout: 'pdf.html',
        orientation: 'landscape',
        encoding: 'UTF-8',
        margin: {
          top: 5,
          bottom: 10,
          left: 7,
          right: 7
        },
        zoom: 1,
        dpi: 75
      end 
    end
  end

  def new_master_to_schedule
    authorize current_user, :has_admin_access?
  end

  def master_to_schedule
    authorize current_user, :has_admin_access?

    @planning = @corporation.planning
    CopyPatientPlanningFromMasterWorker.perform_async(@patient.id, params[:month], params[:year])

    @planning.create_activity :reflect_patient_master, owner: current_user, planning_id: @planning.id, parameters: {year: params[:year].to_i, month: params[:month].to_i, patient_id: @patient.id, patient_name: @patient.try(:name)}
  end

  def payable 
    authorize current_user, :has_access_to_salary_line_items?
    authorize @patient, :same_corporation_as_current_user?

    set_month_and_year_params
    fetch_nurses_grouped_by_team
    fetch_patients_grouped_by_kana

    @first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
    @last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
    @end_of_today_in_japan = (Time.current + 9.hours).end_of_day < @last_day ? (Time.current + 9.hours).end_of_day : @last_day

    @appointments_till_today = @patient.appointments.not_archived.in_range(@first_day..@end_of_today_in_japan).includes(:nurse).order(starts_at: 'asc')

    @invoicing_summary = @patient.invoicing_summary(@first_day..@end_of_today_in_japan)
    
    @cancelled_but_invoiceable_appointments = @appointments_till_today.where(cancelled: true).where.not(total_invoiced: [0, nil])

    @care_manager = @patient.care_plans.valid_at(@first_day).first.try(:care_manager)

    respond_to do |format|
      format.html 
      format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=\"請求書_#{@patient.try(:name)}様_#{params[:y]}年#{params[:m]}月.xlsx\""}
    end
  end

  def commented_appointments
    authorize current_user, :has_admin_access?
    authorize @patient, :same_corporation_as_current_user?
    
    if params[:m].present? && params[:y].present?
      @first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0, 0)
      @last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59, 59)
      
      @commented_appointments = Appointment.commented.edit_not_requested.not_archived.where(patient_id: @patient.id).in_range(@first_day..@last_day).order(:starts_at)
      
      respond_to do |format|
        format.html 
        format.pdf do
          render pdf: "#{@patient.name}様_サービス編集内容_#{@first_day.j_full_year}#{@first_day.strftime('%-m月')}分",
          page_size: 'A4',
          layout: 'pdf.html',
          orientation: 'portrait',
          encoding: 'UTF-8',
          zoom: 1,
          dpi: 75
        end 
      end
    else
      redirect_back fallback_location: current_user_home_path
    end
  end

  def new_extract_care_plan
  end

  def extract_care_plan
    @date = params[:query_date].to_date rescue Date.today 

    @care_plan = @patient.care_plans.valid_at(@date).first 

    @recurring_appointments = @patient.recurring_appointments.where('anchor <= ?', @date).not_terminated_at(@date).not_archived.includes(:completion_report)

    respond_to do |format|
      format.pdf do 
        render pdf: "#{@patient.try(:name)}様_訪問介護計画書_#{@date.j_full_year}#{@date.strftime('%-m月%-d日')}",
        page_size: 'A4',
        layout: 'pdf.html',
        orientation: 'portrait',
        encoding: 'UTF-8',
        zoom: 1,
        dpi: 75
      end
    end
  end


  private

  def set_patient
    @patient = Patient.find(params[:id])
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

  def set_care_managers
    care_manager_corporation_ids = @corporation.care_manager_corporations.ids
    @care_managers = CareManager.where(care_manager_corporation_id: care_manager_corporation_ids).includes(:care_manager_corporation).order(:care_manager_corporation_id)
  end

  def set_teams 
    @teams = @corporation.teams
  end
  
  def set_month_and_year_params
    @selected_year = params[:y].present? ? params[:y] : Date.today.year
    @selected_month = params[:m].present? ? params[:m] : Date.today.month
  end

  def convert_wareki_dates(params)
    if params[:care_plans_attributes].present?
      params[:care_plans_attributes]['0'][:kaigo_certification_date] = Date.parse_jp_date(params[:care_plans_attributes]['0'][:kaigo_certification_date]) rescue nil
      params[:care_plans_attributes]['0'][:kaigo_certification_validity_end] = Date.parse_jp_date(params[:care_plans_attributes]['0'][:kaigo_certification_validity_end]) rescue nil
      params[:care_plans_attributes]['0'][:kaigo_certification_validity_start] = Date.parse_jp_date(params[:care_plans_attributes]['0'][:kaigo_certification_validity_start]) rescue nil
    end
    params[:birthday] = Date.parse_jp_date(params[:birthday]) rescue nil
    params
  end

  def query_by_kana_params(kana_group)
    case kana_group
    when 'あ'
      "kana LIKE 'あ%' OR kana LIKE 'い%'  OR kana LIKE 'う%' OR kana LIKE 'え%' OR kana LIKE 'お%' OR kana LIKE 'ア%' OR kana LIKE 'イ%'  OR kana LIKE 'ウ%' OR kana LIKE 'エ%' OR kana LIKE 'オ%'"
    when 'か'
      "kana LIKE 'か%' OR kana LIKE 'き%'  OR kana LIKE 'く%' OR kana LIKE 'け%' OR kana LIKE 'こ%' OR kana LIKE 'カ%' OR kana LIKE 'キ%'  OR kana LIKE 'ク%' OR kana LIKE 'ケ%' OR kana LIKE 'コ%' OR kana LIKE 'が%' OR kana LIKE 'ぎ%'  OR kana LIKE 'ぐ%' OR kana LIKE 'げ%' OR kana LIKE 'ご%' OR kana LIKE 'ガ%' OR kana LIKE 'ギ%'  OR kana LIKE 'グ%' OR kana LIKE 'ゲ%' OR kana LIKE 'ゴ%'"
    when 'さ'
      "kana LIKE 'さ%' OR kana LIKE 'し%'  OR kana LIKE 'す%' OR kana LIKE 'せ%' OR kana LIKE 'そ%' OR kana LIKE 'サ%' OR kana LIKE 'シ%'  OR kana LIKE 'ス%' OR kana LIKE 'セ%' OR kana LIKE 'ソ%' OR kana LIKE 'ざ%' OR kana LIKE 'じ%'  OR kana LIKE 'ず%' OR kana LIKE 'ぜ%' OR kana LIKE 'ぞ%' OR kana LIKE 'ザ%' OR kana LIKE 'ジ%'  OR kana LIKE 'ズ%' OR kana LIKE 'ゼ%' OR kana LIKE 'ゾ%'"
    when 'た'
      "kana LIKE 'た%' OR kana LIKE 'ち%'  OR kana LIKE 'つ%' OR kana LIKE 'て%' OR kana LIKE 'と%' OR kana LIKE 'タ%' OR kana LIKE 'チ%'  OR kana LIKE 'ツ%' OR kana LIKE 'テ%' OR kana LIKE 'ト%' OR kana LIKE 'だ%' OR kana LIKE 'ぢ%'  OR kana LIKE 'づ%' OR kana LIKE 'で%' OR kana LIKE 'ど%' OR kana LIKE 'ダ%' OR kana LIKE 'ヂ%'  OR kana LIKE 'ヅ%' OR kana LIKE 'デ%' OR kana LIKE 'ド%'"
    when 'な'
      "kana LIKE 'な%' OR kana LIKE 'に%'  OR kana LIKE 'ぬ%' OR kana LIKE 'ね%' OR kana LIKE 'の%' OR kana LIKE 'ナ%' OR kana LIKE 'ニ%'  OR kana LIKE 'ヌ%' OR kana LIKE 'ネ%' OR kana LIKE 'ノ%'"
    when 'は'
      "kana LIKE 'は%' OR kana LIKE 'ひ%'  OR kana LIKE 'ふ%' OR kana LIKE 'へ%' OR kana LIKE 'ほ%' OR kana LIKE 'ハ%' OR kana LIKE 'ヒ%'  OR kana LIKE 'フ%' OR kana LIKE 'ヘ%' OR kana LIKE 'ホ%' OR kana LIKE 'ば%' OR kana LIKE 'び%'  OR kana LIKE 'ぶ%' OR kana LIKE 'べ%' OR kana LIKE 'ぼ%' OR kana LIKE 'ぱ%' OR kana LIKE 'ぴ%'  OR kana LIKE 'ぷ%' OR kana LIKE 'ぺ%' OR kana LIKE 'ぽ%'  OR kana LIKE 'バ%' OR kana LIKE 'ビ%'  OR kana LIKE 'ブ%' OR kana LIKE 'ベ%' OR kana LIKE 'ボ%' OR kana LIKE 'パ%' OR kana LIKE 'ピ%'  OR kana LIKE 'プ%' OR kana LIKE 'ペ%' OR kana LIKE 'ポ%'"
    when 'ま'
      "kana LIKE 'ま%' OR kana LIKE 'み%'  OR kana LIKE 'む%' OR kana LIKE 'め%' OR kana LIKE 'も%' OR kana LIKE 'マ%' OR kana LIKE 'ミ%'  OR kana LIKE 'ム%' OR kana LIKE 'メ%' OR kana LIKE 'モ%'"
    when 'や'
      "kana LIKE 'や%' OR kana LIKE 'ゆ%'  OR kana LIKE 'よ%' OR kana LIKE 'ヤ%' OR kana LIKE 'ユ%' OR kana LIKE 'ヨ%'"
    when 'ら'
      "kana LIKE 'ら%' OR kana LIKE 'り%'  OR kana LIKE 'る%' OR kana LIKE 'れ%' OR kana LIKE 'ろ%' OR kana LIKE 'ラ%' OR kana LIKE 'リ%'  OR kana LIKE 'ル%' OR kana LIKE 'レ%' OR kana LIKE 'ロ%'"
    when 'わ'
      "kana LIKE 'わ%' OR kana LIKE 'を%'  OR kana LIKE 'ん%' OR kana LIKE 'ワ%' OR kana LIKE 'ヲ%' OR kana LIKE 'ン%'"
    when 'カナなし'
      "kana is null OR kana = ''"
    else 
      ""
    end
  end

  def patient_params
    params.require(:patient).permit(:name, :kana, :phone_mail, :phone_number, :address, :gender, :description, :team_id, :handicap_level, :kaigo_level, :nurse_id, :doctor_name, :care_manager_name, :care_manager_id, :second_care_manager_id, :date_of_contract, :insurance_id, :birthday, :kaigo_certification_date, :kaigo_certification_validity_start, :kaigo_certification_validity_end, :ratio_paid_by_patient, :public_assistance_id_1, :public_assistance_receiver_number_1, :public_assistance_id_2, :public_assistance_receiver_number_2, :end_of_contract, :issuing_administration_number, :issuing_administration_name, :emergency_contact_1_name, :emergency_contact_1_address, :emergency_contact_1_phone, :emergency_contact_1_relationship, :emergency_contact_1_living_with_patient, :emergency_contact_2_name, :emergency_contact_2_address, :emergency_contact_2_phone, :emergency_contact_2_relationship, :emergency_contact_2_living_with_patient, caveat_list:[], care_plans_attributes: [:id, :care_manager_id, :kaigo_certification_date, :kaigo_certification_validity_start, :kaigo_certification_validity_end, :kaigo_level, :short_term_goals,:long_term_goals, :family_wishes, :patient_wishes, :handicap_level, insurance_policy: []])
  end
end
