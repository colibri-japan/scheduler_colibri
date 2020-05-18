class CareManagersController < ApplicationController

  before_action :set_corporation
  before_action :set_care_manager_corporation

  def new 
    @care_manager = @care_manager_corporation.care_managers.new()
  end

  def create 
    @care_manager = @care_manager_corporation.care_managers.new(care_manager_params)

    respond_to do |format|
        if @care_manager.save 
            format.html { redirect_to care_manager_corporations_path, notice: "ケアマネが登録されました" }
        else
            format.html { redirect_to care_manager_corporations_path, alert: "ケアマネの登録が失敗しました" }
        end
    end
  end

  def edit
    @care_manager = CareManager.find(params[:id])
    @care_manager_corporations = @corporation.care_manager_corporations
  end
  
  def update
    @care_manager = CareManager.find(params[:id])
  
    respond_to do |format|
      if @care_manager.update(care_manager_params)
        format.html { redirect_to care_manager_corporations_path, notice: "ケアマネが編集されました" }
        format.js
      else
        format.html { redirect_to care_manager_corporations_path, alert: "ケアマネの編集が失敗しました" }
        format.js
      end
    end
  end

  def destroy
    @care_manager = CareManager.find(params[:id])

    respond_to do |format|
      if @care_manager.destroy
        format.html {redirect_to care_manager_corporations_path, notice: 'ケアマネが削除されました'}
      else
        format.html {redirect_to care_manager_corporations_path, alert: 'ケアマネの削除が失敗しました'}
      end
    end 
  end

  def index
    @care_managers = @care_manager_corporation.care_managers.order_by_kana
  end

  private 

  def set_care_manager_corporation
    @care_manager_corporation = CareManagerCorporation.find(params[:care_manager_corporation_id])
  end

  def care_manager_params
    params.require(:care_manager).permit(:name, :kana, :registration_id, :phone_number, :description, :care_manager_corporation_id)
  end

  
end
