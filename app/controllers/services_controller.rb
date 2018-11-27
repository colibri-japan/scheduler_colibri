class ServicesController < ApplicationController

    before_action :set_corporation
    before_action :set_nurse, except: [:destroy, :index, :new, :create]
    before_action :set_service, only: [:edit, :update, :destroy]

    def index
        if params[:nurse_id].present? 
            @nurse =  Nurse.find(params[:nurse_id])
            @services = @corporation.equal_salary == true ? @corporation.services.without_nurse_id.order_by_title.all : @nurse.services.order_by_title.all
        else
            @planning = Planning.find(params[:planning_id])
            @services = @corporation.services.without_nurse_id.order_by_title
            @last_nurse = @corporation.nurses.where(displayable: true).last
        end
    end

    def new
        @service = Service.new
    end

    def create
        @service = @corporation.services.new(service_params)

        if @service.save
            redirect_back fallback_location: root_path, notice: 'サービスタイプが登録されました'
        end
    end

    def edit
    end

    def update
        @service.update(service_params)
    end

    def destroy
        respond_to do |format|
            if @service.destroy 
                format.js
                format.html { redirect_back(fallback_location: root_path)  }
            end
        end
    end

    private
    def set_nurse
        @nurse = params[:nurse_id].present? ? Nurse.find(params[:nurse_id]) : Nurse.find(params[:id])
    end

    def set_corporation
        @corporation = current_user.corporation
    end

    def set_service
        @service = Service.find(params[:id])
    end

    def service_params
        params.require(:service).permit(:title, :unit_wage, :weekend_unit_wage, :recalculate_previous_wages, :equal_salary, :hour_based_wage)
    end
end