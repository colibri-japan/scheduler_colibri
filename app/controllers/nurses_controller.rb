class NursesController < ApplicationController
  before_action :set_corporation
  before_action :set_nurse, only: [:edit, :show, :update, :destroy, :payable]

  def index
  	@nurses = @corporation.nurses.all.order_by_kana
    @nurses = @nurses.where(displayable: true) unless params[:include_undefined] == 'true'
  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
  	@planning = Planning.find(params[:planning_id])
    authorize @nurse, :is_employee?

    @nurses = @corporation.nurses.all.order_by_kana
    @patients = @corporation.patients.all.order_by_kana
    @last_patient = @patients.last
    @last_nurse = @nurses.last

    @activities = PublicActivity::Activity.where(nurse_id: @nurse.id, planning_id: @planning.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)

    set_valid_range
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
      format.html { redirect_to nurses_url, notice: '利用者が削除されました' }
      format.json { head :no_content }
      format.js
    end
  end

  def payable
    authorize current_user, :is_admin?
    authorize @nurse, :is_employee?
    @planning = Planning.find(params[:planning_id])

    delete_previous_temporary_services

    @provided_services = ProvidedService.where(nurse_id: @nurse.id, planning_id: @planning.id, deactivated: false, temporary: false, countable: false)

    @services_till_now = ProvidedService.joins(:appointment).where('appointments.end < ?', Time.current + 9.hours).where(nurse_id: @nurse.id, planning_id: @planning.id, deactivated: false, temporary: false, countable: false).order('appointments.start desc')
    @services_from_now = ProvidedService.joins(:appointment).where('appointments.end >= ?', Time.current + 9.hours).where(nurse_id: @nurse.id, planning_id: @planning.id, deactivated: false, temporary: false, countable: false).order('appointments.start desc')

    mark_services_as_provided

    @nurses = @corporation.nurses.where.not(name: '未定').order_by_kana
    @last_patient = @corporation.patients.last
    @last_nurse = @nurses.last

    set_counter
    @counter.update(service_counts: @services_till_now.count )

    calculate_total_wage
    create_grouped_services

    respond_to do |format|
      format.html
      format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="ヘルパー給与.xlsx"'}
    end
  end


  private

  def set_nurse
    @nurse = Nurse.find(params[:id])
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
    params.require(:nurse).permit(:name, :kana, :address, :phone_number, :phone_mail)
  end

  def calculate_total_wage
    #sum_provided= @provided_services.sum{|e| e.total_wage.present? ? e.total_wage : 0 }
    #@counter.total_wage.present? ? @total_wage = sum_provided + @counter.try(:total_wage) : @total_wage = sum_provided

    @total_till_now = @services_till_now.sum{|service| service.total_wage.present? ? service.total_wage : 0 }
    @total_till_now = @total_till_now + @counter.try(:total_wage) if @counter.total_wage.present?

    @total_from_now = @services_from_now.sum{|service| service.total_wage.present? ? service.total_wage : 0 }
  end

  def set_counter
    @counter = @nurse.provided_services.where(planning_id: @planning.id, countable: true, temporary: false).take

    unless @counter.present?
      @counter = @nurse.provided_services.create!(planning_id: @planning.id, countable: true, provided: true)
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
      matching_services = @services_till_now.where(title: service_title)
      sum_duration = matching_services.sum{|e| e.service_duration.present? ? e.service_duration : 0 }
      sum_total_wage = matching_services.sum{|e| e.total_wage.present? ? e.total_wage : 0 }
      new_service = ProvidedService.create(title: service_title, service_duration: sum_duration, planning_id: @planning.id, nurse_id: @nurse.id, service_counts: matching_services.count, total_wage: sum_total_wage, temporary: true)
      @grouped_services << new_service
    end
  end

end
