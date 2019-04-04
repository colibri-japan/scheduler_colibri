class ServicesController < ApplicationController
    before_action :set_corporation
    before_action :set_nurse, except: [:destroy, :index, :new, :create, :new_merge_and_destroy, :merge_and_destroy]
    before_action :set_service, only: [:edit, :update, :destroy, :new_merge_and_destroy]

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
        @service = @corporation.services.new
    end

    def create
        @service = @corporation.services.new(service_params)

        if @service.save
            redirect_back fallback_location: authenticated_root_path, notice: 'サービスタイプが登録されました'
        end
    end

    def edit
    end

    def update
        if @service.update(service_params)
            RecalculatePreviousWagesWorker.perform_async(@service.id) if @service.recalculate_previous_wages
        end
    end

    def new_merge_and_destroy
        @services = @corporation.services.where(nurse_id: nil).where.not(id: @service.id)
    end

    def merge_and_destroy
        puts params[:id]
        puts params[:destination_service_id]
        MergeAndDestroyServiceWorker.perform_async(params[:id], params[:destination_service_id])
    end

    def destroy
        respond_to do |format|
            if @service.destroy 
                format.js
                format.html { redirect_back fallback_location: authenticated_root_path, notice: 'サービスタイプが削除されました'  }
            end
        end
    end

    private
    def set_nurse
        @nurse = params[:nurse_id].present? ? Nurse.find(params[:nurse_id]) : Nurse.find(params[:id])
    end

    def set_corporation
      @corporation = Corporation.cached_find(current_user.corporation_id)
    end

    def set_service
        @service = Service.find(params[:id])
    end

    def service_params
        params.require(:service).permit(:title, :unit_wage, :weekend_unit_wage, :recalculate_previous_wages, :equal_salary, :hour_based_wage, :planning_id)
    end

    def update_planning_provided_service
        puts  'update method called'
        recalculate = service_params['recalculate_previous_wages'].to_i

        if recalculate == 1
            puts 'evaluated recalculate'
            if @service.equal_salary == true 
                puts 'equal salary is true'
                provided_services_to_update = ProvidedService.where('planning_id = ? AND title = ? AND temporary is false', service_params['planning_id'], service_params['title'])
            else
                puts 'equal salary not true'
                provided_services_to_update = ProvidedService.where('planning_id = ? AND title = ? AND nurse_id = ? AND temporary is false', service_params['planning_id'], service_params['title'], @service.nurse_id)
            end


            provided_services_to_update.each do |provided_service|
                provided_service.unit_cost = provided_service.weekend_holiday_provided_service? ? @service.weekend_unit_wage : @service.unit_wage
                provided_service.skip_callbacks_except_calculate_total_wage = true 
                provided_service.save
            end
        end
    end
end