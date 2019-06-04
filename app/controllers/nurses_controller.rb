class NursesController < ApplicationController
  before_action :set_corporation
  before_action :set_nurse, except: [:index, :new, :create]
  before_action :set_planning, only: [:show, :master, :payable]
  before_action :set_printing_option, only: [:show, :master]
  before_action :set_skills, only: [:new, :edit]

  def index
    @planning = @corporation.planning 
    set_main_nurse
    
    nurses = @corporation.nurses
    
    if params[:team_id].present? 
      team = Team.find(params[:team_id])
      authorize team, :same_corporation_as_current_user?
      nurse_ids = team.nurses.pluck(:id)
      nurses = nurses.where(id: nurse_ids)
    end

    if params[:nurse_ids].present? && params[:nurse_ids] != "null" && params[:nurse_ids] != "undefined"
      ids = params[:nurse_ids].split(',')
      nurses = nurses.where(id: ids)
    end

    full_timers = nurses.where(full_timer: true, displayable: true).order_by_kana
    part_timers = nurses.where(full_timer: false, displayable: true).order_by_kana
    @nurses = full_timers + part_timers

    if params[:include_undefined] == 'true'
      undisplayable = nurses.where(displayable: false)
      @nurses =  undisplayable + @nurses
    end

    @planning = Planning.find(params[:planning_id]) if params[:planning_id].present?

    if stale?(nurses)
      respond_to do |format|
        format.html 
        format.json {render json: @nurses.as_json}
      end
    end

  end

  def show
    authorize @nurse, :same_corporation_as_current_user?

    fetch_nurses_grouped_by_team
    fetch_patients_grouped_by_kana
    @patients_with_services = Patient.joins(:provided_services).select("patients.*, sum(provided_services.service_duration) as sum_service_duration").where(provided_services: {nurse_id: @nurse.id}).where(active: true).group('patients.id').order('sum_service_duration DESC')

    @provided_services_grouped_by_category = ProvidedService.where(nurse_id: @nurse.id, planning_id: @planning.id, cancelled: false).in_range((Date.today - 2.months)..Date.today).not_archived.from_appointments.grouped_by_weighted_category
  end

  def master 
    authorize @planning, :same_corporation_as_current_user? 

    fetch_nurses_grouped_by_team
    fetch_patients_grouped_by_kana
  end

  def edit
  end

  def new
    @nurse = Nurse.new
  end

  def create
    @nurse = Nurse.new(nurse_params)
    @nurse.corporation_id = @corporation.id

    respond_to do |format|
      if @nurse.save
        format.html { redirect_to nurses_path, notice: '従業員が登録されました。' }
      else
        format.html { redirect_to nurses_path, alert: '従業員の登録が失敗しました。' }
      end
    end
  end

  def update
    authorize @nurse, :same_corporation_as_current_user?
    respond_to do |format|
      if @nurse.update(nurse_params)
        format.html {redirect_back(fallback_location: authenticated_root_path, notice: '従業員の情報がアップデートされました')}
      else
        format.html {redirect_back(fallback_location: authenticated_root_path, alert: '従業員の情報のアップデートが失敗しました')}
      end
    end
  end

  def destroy
    authorize @nurse, :same_corporation_as_current_user?
    @nurse.destroy
    respond_to do |format|
      format.html { redirect_to nurses_url, notice: '従業員が削除されました' }
      format.json { head :no_content }
      format.js
    end
  end

  def new_reminder_email
  end

  def send_reminder_email
    message = nurse_params[:custom_email_message]
    subject = nurse_params[:custom_email_subject]
    custom_email_days = nurse_params[:custom_email_days]

    SendNurseReminderWorker.perform_async(@nurse.id, custom_email_days, {custom_email_message: message, custom_email_subject: subject})
  end

  def payable
    authorize current_user, :has_access_to_provided_services?
    authorize @nurse, :same_corporation_as_current_user?

    set_month_and_year_params
    fetch_nurses_grouped_by_team
    fetch_patients_grouped_by_kana

    first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0).beginning_of_month
    last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59).end_of_month
    end_of_today_in_japan = (Time.current + 9.hours).end_of_day < last_day ? (Time.current + 9.hours).end_of_day : last_day

    @services_till_today = ProvidedService.not_archived.includes(:appointment, :patient).where(nurse_id: @nurse.id, planning_id: @planning.id).in_range(first_day..end_of_today_in_japan)
    @services_from_today = ProvidedService.not_archived.includes(:appointment, :patient).where(nurse_id: @nurse.id, planning_id: @planning.id).in_range(end_of_today_in_japan..last_day).order(service_date: 'asc')
    calculate_total_wage

    set_sort_direction
    @services_from_salary_rules = @services_till_today.from_salary_rules.order(service_date: 'asc')
    @services_from_appointments = @services_till_today.from_appointments.order("service_date #{@sort_direction}")

    @unverified_services_count = @services_from_appointments.where(appointments: {edit_requested: false}).where(cancelled: false, archived_at: nil).unverified.count

    @total_days_worked = [[@services_till_today.from_appointments.where(appointments: {edit_requested: false, cancelled: false}).pluck(:service_date).map{|e| e.strftime('%m-%d')}.uniq] + [@services_till_today.from_salary_rules.where(salary_rule_id: nil).pluck(:service_date).map{|e| e.strftime('%m-%d')}.uniq]].flatten.uniq.count
    
    group_services_till_now_by_title
    fetch_time_worked_vs_time_pending

    respond_to do |format|
      format.html
      format.xlsx { response.headers['Content-Disposition'] = "attachment; filename=\"給与明細書_#{@nurse.try(:name)}_#{params[:y]}年#{params[:m]}月.xlsx\""}
    end
  end

  def new_master_to_schedule
    authorize current_user, :has_admin_access?
  end

  def master_to_schedule
    authorize current_user, :has_admin_access?

    @planning = @corporation.planning

    CopyNursePlanningFromMasterWorker.perform_async(@nurse.id, params[:month], params[:year])

    redirect_to planning_nurse_path(@planning, @nurse), notice: "#{@nurse.name}のサービスの反映が始まりました。数秒後にリフレッシュしてください。"
  end


  private

  def set_nurse
    @nurse = Nurse.find(params[:id])
  end

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end
  
  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def set_valid_range
    @start_valid = Date.new(@planning.business_year, @planning.business_month, 1).strftime("%Y-%m-%d")
  end

  def set_skills
    @skills = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {taggable_type: 'Nurse', taggable_id: @corporation.nurses.ids, context: 'skills'})
  end

  def nurse_params
    params.require(:nurse).permit(:name, :kana, :address, :phone_number, :phone_mail, :team_id, :description, :full_timer, :reminderable,:custom_email_subject, :custom_email_message, skill_list:[], custom_email_days: [])
  end

  def calculate_total_wage
    @total_till_today = @services_till_today.sum(:total_wage) || 0
    @total_from_today = @services_from_today.sum(:total_wage) || 0
  end

  def group_services_till_now_by_title
    countable_services = @services_till_today.where(appointments: {edit_requested: false, cancelled: false})
    @grouped_services = ProvidedService.where(id: countable_services.ids).order(:title).group(:title).select('title, sum(service_duration) as sum_duration, count(*), sum(total_wage) as sum_total_wage')
    @grouped_services_sum_duration = countable_services.sum(:service_duration)
    @grouped_services_sum_count = countable_services.count
    @grouped_services_sum_total_wage = countable_services.sum(:total_wage)
  end

  def fetch_time_worked_vs_time_pending
    @total_time_worked = @services_till_today.from_appointments.where(appointments: {edit_requested: false, cancelled: false}).sum(:service_duration) || 0
    @total_time_pending =  @services_from_today.from_appointments.where(appointments: {edit_requested: false, cancelled: false}).sum(:service_duration) || 0
  end


  def set_printing_option
    @printing_option = @corporation.printing_option
  end

  def set_month_and_year_params
    @selected_year = params[:y].present? ? params[:y] : Date.today.year
    @selected_month = params[:m].present? ? params[:m] : Date.today.month
  end

  def set_sort_direction 
    @sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end
