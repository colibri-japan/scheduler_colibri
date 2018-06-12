class NursesController < ApplicationController
  before_action :set_corporation
  before_action :set_nurse, only: [:edit, :show, :update, :destroy]

  def index
  	@nurses = @corporation.nurses.all
  	@planning = Planning.find(params[:planning_id]) if params[:planning_id].present?
  end

  def show
  	@planning = Planning.find(params[:planning_id])
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
    respond_to do |format|
      if @nurse.update(nurse_params)
        format.html {redirect_to nurses_path, notice: 'ヘルパーの情報がアップデートされました' }
      else
        format.html {render :edit}
      end
    end
  end

  def destroy
    @nurse.destroy
    respond_to do |format|
      format.html { redirect_to nurses_url, notice: '利用者が削除されました' }
      format.json { head :no_content }
      format.js
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
    params.require(:nurse).permit(:name, :address, :phone_number, :phone_mail)
  end
end
