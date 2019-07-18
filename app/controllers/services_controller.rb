class ServicesController < ApplicationController
    before_action :set_corporation
    before_action :set_service, only: [:edit, :update, :new_merge_and_destroy]

    def index
        if params[:nurse_id].present? 
            @nurse =  Nurse.find(params[:nurse_id])
            @services = @nurse.services.order_by_title.all
        else
            @planning = Planning.find(params[:planning_id])
            @services = @corporation.services.without_nurse_id.order_by_title
            @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
        end

        fresh_when etag: @services, last_modified: @services.maximum(:updated_at)
    end

    def new
        authorize current_user, :has_admin_access?
        
        @service = @corporation.services.new
    end
    
    def create
        authorize current_user, :has_admin_access?
        
        @service = @corporation.services.new(service_params)
        
        if @service.save
            redirect_back fallback_location: authenticated_root_path, notice: 'サービスタイプが登録されました'
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
                format.html { redirect_back fallback_location: authenticated_root_path, notice: 'サービスの詳細が編集されました' }
                format.js
                RecalculatePreviousWagesWorker.perform_async(@service.id) if @service.recalculate_previous_wages
            else
                format.html { redirect_back fallback_location: authenticated_root_path, alert: 'サービスの編集が失敗しました' }
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

        redirect_back fallback_location: authenticated_root_path, notice: 'サービスの統合.削除を開始しました。数分後に終了します。'
    end

    private

    def set_nurse_if_present
        @nurse = Nurse.find(params[:nurse_id]) if params[:nurse_id].present? 
    end

    def set_service
        @service = Service.find(params[:id])
    end

    def service_params
        params.require(:service).permit(:title, :official_title, :service_code, :unit_wage, :weekend_unit_wage, :recalculate_previous_wages, :hour_based_wage, :category_1, :category_2, :category_ratio, :unit_credits, :recalculate_previous_credits_and_invoice, :credit_calculation_method, :insurance_category_1, :insurance_category_2, :invoiced_amount)
    end

end