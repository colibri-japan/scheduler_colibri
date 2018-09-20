class NursesController < ApplicationController
  before_action :set_corporation
  before_action :set_nurse, only: [:edit, :show, :update, :destroy, :payable, :master]
  before_action :set_planning, only: [:show, :master, :payable]

  def index
    full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana
    @nurses = full_timers + part_timers
    if  params[:include_undefined] == 'true'
      undisplayable = @corporation.nurses.where(displayable: false)
      @nurses = @nurses + undisplayable 
    end
  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
    authorize @nurse, :is_employee?

    @full_timers = @corporation.nurses.where(full_timer: true).order_by_kana
    @part_timers = @corporation.nurses.where(full_timer: false).order_by_kana
    @patients = @corporation.patients.all.order_by_kana
    @last_patient = @patients.last
    @last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last

    @activities = PublicActivity::Activity.where(nurse_id: @nurse.id, planning_id: @planning.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)

    set_valid_range
  end

  def master 
    authorize @planning, :is_employee? 

    @full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    @part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana
    @patients = @corporation.patients.all.order_by_kana
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
        format.html {redirect_to nurses_path, notice: 'ヘルパーの情報がアップデートされました' }
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

  def payable
    authorize current_user, :is_admin?
    authorize @nurse, :is_employee?

    delete_previous_temporary_services

    @provided_services = ProvidedService.where(nurse_id: @nurse.id, planning_id: @planning.id, deactivated: false, temporary: false, countable: false)

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
    valid_month = @planning.business_month
    valid_year = @planning.business_year
    @start_valid = Date.new(valid_year, valid_month, 1).strftime("%Y-%m-%d")
    @end_valid = Date.new(valid_year, valid_month +1, 1).strftime("%Y-%m-%d")
  end

  def nurse_params
    params.require(:nurse).permit(:name, :kana, :address, :phone_number, :phone_mail, :full_timer, :reminderable)
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

    if unprovided_services.present?
      unprovided_services.each do |provided_service|
        provided_service.update(provided: true)
      end
    end
  end

  def create_grouped_services
    service_types = []
    @grouped_services = []
    @services_till_now.each do |service|
      service_types << service.title unless service_types.include?(service.title)
    end

    service_types.each do |service_title|
      matching_services = @services_till_now.where(title: service_title).all
      
      sum_duration = matching_services.sum{|e| e.service_duration.present? ? e.service_duration : 0 }
      sum_total_wage = matching_services.sum{|e| e.total_wage.present? ? e.total_wage : 0 }
      sum_counts = matching_services.sum{|e| e.service_counts.present? ? e.service_counts : 1 }
      hour_based = matching_services.first.hour_based_wage

      new_service = ProvidedService.create(title: service_title, service_duration: sum_duration, planning_id: @planning.id, nurse_id: @nurse.id, service_counts: sum_counts, total_wage: sum_total_wage, temporary: true, hour_based_wage: hour_based)
      @grouped_services << new_service
    end
  end

end
