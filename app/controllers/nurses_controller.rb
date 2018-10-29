class NursesController < ApplicationController
  before_action :set_corporation
  before_action :set_nurse, except: [:index, :new, :create]
  before_action :set_planning, only: [:show, :master, :payable, :master_to_schedule]

  def index
    full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana
    @nurses = full_timers + part_timers

    if  params[:include_undefined] == 'true'
      undisplayable = @corporation.nurses.where(displayable: false)
      @nurses =  undisplayable + @nurses
    end
  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
    authorize @nurse, :is_employee?

    @full_timers = @corporation.nurses.where(full_timer: true).order_by_kana
    @part_timers = @corporation.nurses.where(full_timer: false).order_by_kana
    @patients = @corporation.patients.where(active: true).order_by_kana
    @patients_with_services = Patient.joins(:provided_services).select("patients.*, sum(provided_services.service_duration) as sum_service_duration").where(provided_services: {nurse_id: @nurse.id}).where(active: true).group('patients.id').order('sum_service_duration DESC')
    @last_patient = @patients.last
    @last_nurse = @nurse

    @provided_services_shintai = ProvidedService.where(planning_id: @planning.id, nurse_id: @nurse.id).where("title LIKE ?", "%身%").sum(:service_duration)
    @provided_services_seikatsu = ProvidedService.where(planning_id: @planning.id, nurse_id: @nurse.id).where("title LIKE ?", "%生%").sum(:service_duration)

    puts @provided_services_seikatsu
    puts @provided_services_shintai

    @activities = PublicActivity::Activity.where(nurse_id: @nurse.id, planning_id: @planning.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)

    set_valid_range
  end

  def master 
    authorize @planning, :is_employee? 

    @full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    @part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana
    @patients = @corporation.patients.where(active: true).order_by_kana
    @last_patient = @patients.last
    @last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last

    set_valid_range
		@admin = current_user.admin.to_s
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
        format.html { redirect_to nurses_path }
      else
        format.html { render :new }
      end
    end
  end

  def update
    authorize @nurse, :is_employee?
    respond_to do |format|
      if @nurse.update(nurse_params)
        format.html {redirect_back(fallback_location: root_path, notice: 'ヘルパーの情報がアップデートされました')}
      else
        format.html {render :edit}
      end
    end
  end

  def destroy
    authorize @nurse, :is_employee?
    @nurse.destroy
    respond_to do |format|
      format.html { redirect_to nurses_url, notice: 'ヘルパーが削除されました' }
      format.json { head :no_content }
      format.js
    end
  end

  def new_reminder_email
  end

  def send_reminder_email
    message = nurse_params[:custom_email_message]
    custom_email_days = nurse_params[:custom_email_days]
    subject = nurse_params[:custom_email_subject]

    @nurse.send_service_reminder(custom_email_days, {custom_email_message: message, custom_email_subject: subject})
  end

  def payable
    authorize current_user, :is_admin?
    authorize @nurse, :is_employee?

    delete_previous_temporary_services

    @provided_services = ProvidedService.active.where(nurse_id: @nurse.id, planning_id: @planning.id, temporary: false, countable: false)

    now_in_Japan = Time.current + 9.hours
    @services_till_now = @provided_services.where('service_date < ?', now_in_Japan).order(service_date: 'asc')
    @services_from_now = @provided_services.where('service_date >= ?', now_in_Japan).order(service_date: 'asc')

    mark_services_as_provided

    @full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    @part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana
    @last_patient = @corporation.patients.last
    @last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last

    set_counter
    @counter.update(service_counts: @services_till_now.where.not(appointment_id: nil).count )

    calculate_total_wage
    @total_time_worked = @services_till_now.sum{|e|   e.service_duration.present? ? e.service_duration : 0 } 
    
    @total_time_pending =  @services_from_now.sum{|e|  e.service_duration.present? ? e.service_duration : 0 } 
    create_grouped_services

    @chart_wage_data = @provided_services.group(:provided).sum(:total_wage)

    respond_to do |format|
      format.html
      format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="ヘルパー給与.xlsx"'}
    end
  end

  def master_to_schedule
    authorize current_user, :is_admin?

    CopyNursePlanningFromMasterWorker.perform_async(@nurse.id, @planning.id)

    redirect_to planning_nurse_path(@planning, @nurse), notice: "#{@nurse.name}のサービスの反映が始まりました。数秒後にリフレッシュしてください。"
  end


  private

  def set_nurse
    @nurse = Nurse.find(params[:id])
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

  def set_planning
    @planning = Planning.find(params[:planning_id])
  end

  def set_valid_range
    @start_valid = Date.new(@planning.business_year, @planning.business_month, 1).strftime("%Y-%m-%d")
  end

  def nurse_params
    params.require(:nurse).permit(:name, :kana, :address, :phone_number, :phone_mail, :description, :full_timer, :reminderable,:custom_email_subject, :custom_email_message, skill_list:[], custom_email_days: [])
  end

  def calculate_total_wage
    @total_till_now = @services_till_now.sum{|service| service.total_wage.present? ? service.total_wage : 0 }
    @total_till_now = @total_till_now + @counter.try(:total_wage) if @counter.total_wage.present?

    @total_from_now = @services_from_now.sum{|service| service.total_wage.present? ? service.total_wage : 0 }
  end

  def set_counter
    @counter = @nurse.provided_services.where(planning_id: @planning.id, countable: true, temporary: false).take

    unless @counter.present?
      @counter = @nurse.provided_services.create!(planning_id: @planning.id, countable: true, provided: true, hour_based_wage: false)
    end
  end

  def delete_previous_temporary_services
    services_to_delete = ProvidedService.where(temporary: true, nurse_id: @nurse.id)
    services_to_delete.delete_all
  end

  def mark_services_as_provided
    unprovided_services = @services_till_now.where(provided: false)

    unprovided_services.update_all(provided: true) if unprovided_services.present?
  end

  def create_grouped_services
    service_types = []
    @grouped_services = []
    @services_till_now.each do |service|
      service_types << service.title unless service_types.include?(service.title)
    end

    service_types.each do |service_title|
      matching_provided_services = @services_till_now.where(title: service_title).all
      
      sum_duration = matching_provided_services.sum{|e| e.service_duration.present? ? e.service_duration : 0 }
      sum_total_wage = matching_provided_services.sum{|e| e.total_wage.present? ? e.total_wage : 0 }
      sum_counts = matching_provided_services.sum{|e| e.service_counts.present? ? e.service_counts : 1 }
      hour_based = matching_provided_services.first.hour_based_wage

      matching_service = @corporation.equal_salary == true ? Service.where(corporation_id: @corporation.id, title: service_title).first : Service.where(corporation_id: @corporation.id, title: service_title, nurse_id: @nurse.id).first
      unit_cost = matching_service.unit_wage if matching_service.present?
      new_service = ProvidedService.create(title: service_title, service_duration: sum_duration, unit_cost: unit_cost, planning_id: @planning.id, nurse_id: @nurse.id, service_counts: sum_counts, total_wage: sum_total_wage, temporary: true, hour_based_wage: hour_based)
      @grouped_services << new_service
    end
  end

end
