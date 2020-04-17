class ServicesController < ApplicationController
    before_action :set_corporation
    before_action :set_planning, only: :index
    before_action :set_main_nurse, only: :index
    before_action :set_service, only: [:edit, :update, :new_merge_and_destroy]

    def index
        @services = @corporation.services.without_nurse_id.order_by_title
    end

    def new
        authorize current_user, :has_admin_access?
        
        @service = @corporation.services.new
    end
    
    def create
        authorize current_user, :has_admin_access?
        
        @service = @corporation.services.new(service_params)
        
        if @service.save
            redirect_back fallback_location: current_user_home_path, notice: 'サービスタイプが登録されました'
        end
    end
    
    def edit
        authorize current_user, :has_admin_access?
        authorize @service, :same_corporation_as_current_user?
        
        set_nurse_if_present
    end
    
    def update
        authorize current_user, :has_admin_access?
        authorize @service, :same_corporation_as_current_user?

        set_nurse_if_present
        respond_to do |format|
            if @service.update(service_params)
                format.html { redirect_back fallback_location: current_user_home_path, notice: 'サービスの詳細が編集されました' }
                format.js
            else
                format.html { redirect_back fallback_location: current_user_home_path, alert: 'サービスの編集が失敗しました' }
                format.js
            end
        end
    end

    def new_merge_and_destroy
        authorize current_user, :has_admin_access?
        authorize @service, :same_corporation_as_current_user?
        
        @services = @corporation.services.where(nurse_id: nil).where.not(id: @service.id)
    end
    
    def merge_and_destroy
        authorize current_user, :has_admin_access?
        @merged_service = Service.find(params[:id])
        @destination_service = Service.find(params[:destination_service_id])
        authorize @merged_service, :same_corporation_as_current_user?
        authorize @destination_service, :same_corporation_as_current_user?

        MergeAndDestroyServiceWorker.perform_async(params[:id], params[:destination_service_id])

        redirect_back fallback_location: current_user_home_path, notice: 'サービスの統合.削除を開始しました。数分後に終了します。'
    end

    private

    def set_nurse_if_present
        @nurse = Nurse.find(params[:nurse_id]) if params[:nurse_id].present? 
    end

    def set_service
        @service = Service.find(params[:id])
    end

    def service_params
        params.require(:service).permit(:title, :official_title, :service_code, :unit_wage, :weekend_unit_wage, :hour_based_wage, :category_1, :category_2, :category_ratio, :unit_credits, :credit_calculation_method, :inside_insurance_scope, :insurance_service_category, :invoiced_amount)
    end

end