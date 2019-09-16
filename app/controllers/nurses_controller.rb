class NursesController < ApplicationController
  before_action :set_corporation
  before_action :set_nurse, except: [:index, :new, :create, :master_availabilities, :smart_search, :smart_search_results]
  before_action :set_planning, only: [:show, :master, :payable]
  before_action :set_printing_option, only: [:show, :master, :master_availabilities]
  before_action :set_skills, only: [:new, :edit, :smart_search]
  before_action :set_wishes, only: [:new, :edit, :smart_search]
  before_action :set_wished_areas, only: [:new, :edit, :smart_search]

  def index
    @planning = @corporation.planning 
    set_main_nurse
    
    nurses = @corporation.nurses.not_archived
    
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

    #reporting lines that need to be changed
    @patients_with_services = Patient.joins(:appointments).select("patients.*, sum(appointments.duration) as sum_duration").where(appointments: {nurse_id: @nurse.id, archived_at: nil, cancelled: false, edit_requested: false}).active.group('patients.id').order('sum_duration DESC')
    @appointments_grouped_by_category = @nurse.appointments.operational.where(planning_id: @planning.id).in_range((Date.today - 2.months)..Date.today).grouped_by_weighted_category
    
    respond_to do |format|
      format.js 
      format.html
    end
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
    params = nurse_params
    params = convert_wareki_dates(params)

    @nurse = Nurse.new(params)
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

    params = nurse_params 
    params = convert_wareki_dates(params)

    respond_to do |format|
      if @nurse.update(params)
        format.js
        format.html {redirect_back(fallback_location: authenticated_root_path, notice: '従業員の情報がアップデートされました')}
      else
        format.js
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

  def archive
    authorize @nurse, :same_corporation_as_current_user?

    @nurse.archive!
    respond_to do |format|
      format.html { redirect_to nurses_url, notice: '従業員が削除されました。過去の実績は削除されません。' }
    end
  end

  def smart_search
  end

  def smart_search_results
    @nurses = @corporation.nurses.not_archived.includes(:skills, :wishes, :wished_areas)
    @nurses = @nurses.tagged_with(params[:skill_list], on: :skills, any: true) if params[:skill_list].present?
    @nurses = @nurses.tagged_with(params[:wish_list], on: :wishes, any: true) if params[:wish_list].present?
    @nurses = @nurses.tagged_with(params[:wished_area_list], on: :wished_areas, any: true) if params[:wished_area_list].present?
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
    authorize current_user, :has_access_to_salary_line_items?
    authorize @nurse, :same_corporation_as_current_user?

    set_month_and_year_params
    fetch_nurses_grouped_by_team
    fetch_patients_grouped_by_kana

    set_sort_direction

    first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0).beginning_of_month
    last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59).end_of_month
    end_of_today_in_japan = (Time.current + 9.hours).end_of_day < last_day ? (Time.current + 9.hours).end_of_day : last_day

    @appointments_till_today = @nurse.appointments.not_archived.includes(:patient, :service).in_range(first_day..end_of_today_in_japan).order("starts_at #{@sort_direction}")
    @salary_line_items = @nurse.salary_line_items.not_from_appointments.in_range(first_day..end_of_today_in_japan)
    @unverified_services_count = @appointments_till_today.operational.unverified.count

    @grouped_appointments = @nurse.appointments.operational.in_range(first_day..end_of_today_in_japan).order(:title).group(:title).select('title, sum(duration) as sum_duration, count(*), sum(total_wage) as sum_total_wage')

    @total_days_worked = @nurse.days_worked_in_range(first_day..end_of_today_in_japan)
    @total_time_worked = @appointments_till_today.operational.sum(:duration) || 0 
    @total_time_pending = @nurse.appointments.not_archived.in_range(end_of_today_in_japan..last_day).sum(:duration) || 0
    @percentage_of_time_worked = @total_time_worked + @total_time_pending == 0 ? 100 : (@total_time_worked.to_f * 100 / (@total_time_pending + @total_time_worked)).round(1)
    @percentage_of_time_pending = 100 - @percentage_of_time_worked

    @appointments_grouped_by_category = @nurse.appointments.operational.where(planning_id: @planning.id).in_range(first_day..end_of_today_in_japan).grouped_by_weighted_category

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

    @planning.create_activity :reflect_nurse_master, owner: current_user, planning_id: @planning.id, parameters: {year: params[:year].to_i, month: params[:month].to_i, nurse_name: @nurse.try(:name), nurse_id: @nurse.id}
  end

  def master_availabilities
    @query_day = params[:date].to_date rescue nil
    @text = params[:text]

    @master_availabilities = @query_day.present? ? @corporation.nurses.displayable.master_availabilities_per_slot_and_wday(@query_day) : []

    respond_to do |format|
      format.pdf do 
        render pdf: '空き情報',
        page_size: 'A4',
        layout: 'pdf.html',
        orientation: 'landscape',
        encoding: 'UTF-8',
        zoom: 1,
        dpi: 75
      end
    end
  end

  def recalculate_salary
    if params[:y].present? && params[:m].present?
      RecalculateNurseMonthlyWageWorker.perform_async(@nurse.id, params[:y], params[:m])

      redirect_back(fallback_location: authenticated_root_path, notice: "#{@nurse.name}の給与を計算中です。")
    else
      redirect_back(fallback_location: authenticated_root_path)
    end
  end


  private

  def set_nurse
    @nurse = Nurse.find(params[:id])
  end

  def set_valid_range
    @start_valid = Date.new(@planning.business_year, @planning.business_month, 1).strftime("%Y-%m-%d")
  end

  def set_skills
    @skills = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {taggable_type: 'Nurse', taggable_id: @corporation.nurses.ids, context: 'skills'})
  end

  def set_wishes
    @wishes = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {taggable_type: 'Nurse', taggable_id: @corporation.nurses.ids, context: 'wishes'})
  end

  def set_wished_areas
    @wished_areas = ActsAsTaggableOn::Tag.includes(:taggings).where(taggings: {taggable_type: 'Nurse', taggable_id: @corporation.nurses.ids, context: 'wished_areas'})
  end

  def nurse_params
    params.require(:nurse).permit(:name, :kana, :address, :phone_number, :phone_mail, :team_id, :description, :full_timer, :reminderable,:custom_email_subject, :days_worked, :custom_email_message, :monthly_wage, :profession, :contract_date, skill_list:[], wish_list: [], wished_area_list: [], custom_email_days: [])
  end

  def set_printing_option
    @printing_option = @corporation.printing_option
  end

  def convert_wareki_dates(params)
    params[:contract_date] = Date.parse(params[:contract_date]) rescue nil
    params
  end

  def set_month_and_year_params
    @selected_year = params[:y].present? ? params[:y] : Date.today.year
    @selected_month = params[:m].present? ? params[:m] : Date.today.month
  end

  def set_sort_direction 
    @sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end
