class CareManagerCorporationsController < ApplicationController

  before_action :set_corporation

  def index 
    @planning = @corporation.planning
    set_main_nurse
    @care_manager_corporations = @corporation.care_manager_corporations.includes(:care_managers)

    fresh_when etag: @care_manager_corporations, last_modified: @care_manager_corporations.maximum(:updated_at)
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

  def destroy
    @care_manager_corporation = CareManagerCorporation.find(params[:id])

    respond_to do |format|
      if @care_manager_corporation.destroy 
        format.html { redirect_to care_manager_corporations_path, notice: '居宅介護支援事業所が削除されました' }
      else
        format.html { redirect_to care_manager_corporations_path, alert: '居宅介護支援事業所の削除が失敗しました' }
      end
    end
  end
  
  def teikyohyo
    authorize current_user, :has_admin_access?
    
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
          layout: 'pdf.html',
          orientation: 'landscape',
          encoding: 'UTF-8',
          margin: {
            top: 7,
            bottom: 10,
            left: 7,
            right: 7
          },
          zoom: 1,
          dpi: 75
        end 
      end
    else
      redirect_back fallback_location: authenticated_root_path
    end
  end

  def commented_appointments
    authorize current_user, :has_admin_access?
    
    if params[:m].present? && params[:y].present?
      @care_manager_corporation = CareManagerCorporation.find(params[:id])
      @first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0, 0)
      @last_day = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59, 59)
      
      @patients_with_commented_services = Appointment.includes(:patient).commented.edit_not_requested.not_archived.where(patient_id: Patient.active.from_care_manager_corporation(@care_manager_corporation.id).pluck(:id)).in_range(@first_day..@last_day).order(:starts_at).group_by {|appointment| appointment.patient.name}

      respond_to do |format|
        format.html 
        format.pdf do
          render pdf: "#{@care_manager_corporation.name}様_サービス編集内容_#{@first_day.strftime('%Jy年%Jm月')}分",
          page_size: 'A4',
          layout: 'pdf.html',
          orientation: 'portrait',
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
