class NurseServiceWagesController < ApplicationController

    before_action :set_corporation
    before_action :set_nurse

    def index 
        @services = @corporation.services.without_nurse_id
        @nurse_service_wages = @nurse.nurse_service_wages.pluck(:service_id, :unit_wage)
    end

    def set_nurse_wage
        authorize current_user, :has_admin_access?
        authorize Nurse.find(params[:nurse_id]), :same_corporation_as_current_user?
        authorize Service.find(params[:service_id]), :same_corporation_as_current_user?
        
        @nurse_service_wage = NurseServiceWage.where(nurse_id: params[:nurse_id], service_id: params[:service_id]).first_or_create
        @nurse_service_wage.update(unit_wage: params[:unit_wage].to_i)
    end

    private

    def set_nurse
        @nurse = Nurse.find(params[:nurse_id])
    end

end
