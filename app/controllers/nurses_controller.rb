class NursesController < ApplicationController
  before_action :set_corporation
  before_action :set_nurse, only: [:edit, :show, :update, :destroy, :payable]

  def index
  	@nurses = @corporation.nurses.all.order_by_kana
  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
  	@planning = Planning.find(params[:planning_id])
    authorize @nurse, :is_employee?

    @nurses = @corporation.nurses.all.order_by_kana

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

    @plannings = @corporation.plannings.all
    params[:p].present? && @plannings.ids.include?(params[:p].to_i) ? @planning = Planning.find(params[:p].to_i) : @planning = @plannings.last

    #retrieves all provided services and calculates moving fees
    @provided_services = @nurse.provided_services.where(planning_id: @planning.id, countable: false, temporary: false).order(created_at: 'desc').includes(:payable, :patient)
    set_counter
    @counter.update(service_counts: @provided_services.count )

    #calculate total
    sum_provided= @provided_services.sum{|e| e.total_wage.present? ? e.total_wage : 0 }
    @counter.total_wage.present? ? @total_wage = sum_provided + @counter.try(:total_wage) : @total_wage = sum_provided

    #creates temporary provided_services for grouped services
    already_seen = []
    @grouped_services = []
    @provided_services.each do |service|
      already_seen << service.title unless already_seen.include?(service.title)
    end

    already_seen.each do |service_title|
      matching_services = @provided_services.where(title: service_title)
      sum_duration = matching_services.sum{|e| e.service_duration.present? ? e.service_duration : 0 }
      sum_total_wage = matching_services.sum{|e| e.total_wage.present? ? e.total_wage : 0 }
      new_service = ProvidedService.create(title: service_title, service_duration: sum_duration, planning_id: @planning.id, nurse_id: @nurse.id, total_wage: sum_total_wage, temporary: true)
      @grouped_services << new_service
    end
    
    #response

    respond_to do |format|
      format.html
      format.csv { send_data @provided_services.to_csv }
      format.xls
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

  def set_counter
    @counter = @nurse.provided_services.where(planning_id: @planning.id, countable: true, temporary: false).take

    unless @counter.present?
      @counter = @nurse.provided_services.create!(planning_id: @planning.id, countable: true)
    end
  end

  def update_counter
  end
end
