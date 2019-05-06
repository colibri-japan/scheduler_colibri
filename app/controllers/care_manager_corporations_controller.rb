class CareManagerCorporationsController < ApplicationController

  before_action :set_corporation

  def index 
    @care_manager_corporations = @corporation.care_manager_corporations.includes(:care_managers)
  end

  def new 
    @care_manager_corporation = @corporation.care_manager_corporations.new()
  end

  def create 
    @care_manager_corporation = @corporation.care_manager_corporations.new(care_manager_corporations_params)

    respond_to do |format|
        if @care_manager_corporation.save 
            format.html { redirect_to care_manager_corporations_path, notice: "事業所がセーブされました" }
        else
            format.html { redirect_to care_manager_corporations_path, alert: "事業所の登録が失敗しました" }
        end
    end
  end

  def edit 
    @care_manager_corporation = CareManagerCorporation.find(params[:id])
  end

  def update 
    @care_manager_corporation = CareManagerCorporation.find(params[:id])

    @care_manager_corporation.update(care_manager_corporations_params)
  end

  private 

  def care_manager_corporations_params
    params.require(:care_manager_corporation).permit(:name, :address, :phone_number, :description)
  end

  
end
