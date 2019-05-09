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
  
  def teikyohyo
    if params[:m].present? && params[:y].present?
      @care_manager_corporation = CareManagerCorporation.find(params[:id])
      @first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0, 0)
      @last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59, 59)
      
      @patients_with_services_and_dates = @care_manager_corporation.teikyohyo_data(@first_day, @last_day)

      respond_to do |format|
        format.html 
        format.pdf do
          render pdf: "#{@care_manager_corporation.name}様_提供表_#{@first_day.strftime('%Jy年%Jm月')}分",
          page_size: 'A4',
          template: 'care_manager_corporations/teikyohyo.html.erb',
          orientation: 'landscape',
          encoding: 'UTF-8',
          zoom: 1,
          dpi: 75
        end 
      end
    else
      redirect_back fallback_location: authenticated_root_path
    end
  end

  private 

  def care_manager_corporations_params
    params.require(:care_manager_corporation).permit(:name, :address, :phone_number, :description)
  end

  
end
