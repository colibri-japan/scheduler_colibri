class SalaryRulesController < ApplicationController
    before_action :set_corporation

    def index
      @salary_rules = @corporation.salary_rules
    end

    def new 
      set_nurses_and_services

      @salary_rule = @corporation.salary_rules.new
    end

    def create 
      @salary_rule = @corporation.salary_rules.new(salary_rules_params)

      @salary_rule.save
    end

    def edit 
      set_nurses_and_services
      @salary_rule = SalaryRule.find(params[:id])
    end

    def update  
      @salary_rule = SalaryRule.find(params[:id])

      @salary_rule.update(salary_rules_params)
    end

    private

    def set_corporation
      @corporation = Corporation.cached_find(current_user.corporation_id)
    end

    def set_nurses_and_services
      @nurses = @corporation.nurses.displayable
      @services = @corporation.services.where(nurse_id: nil)
    end

    def salary_rules_params
      params.require(:salary_rule).permit(:title, :target_all_nurses, :target_all_services, :date_constraint, :expires_at, :operator, :argument, :hour_based, nurse_id_list: [], service_title_list: [])
    end

end