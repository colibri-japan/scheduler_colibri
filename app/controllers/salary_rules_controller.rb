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

      respond_to do |format|
        if @salary_rule.save 
          format.js 
          format.html { redirect_back fallback_location: authenticated_root_path, notice: "手当が計算され、セーブされました" }
        else
          format.js
          format.html { redirect_back fallback_location: authenticated_root_path, notice: "手当の計算が失敗しました" }
        end
      end
    end

    def edit 
      set_nurses_and_services
      @salary_rule = SalaryRule.find(params[:id])
    end

    def update  
      @salary_rule = SalaryRule.find(params[:id])

      @salary_rule.update(salary_rules_params)
    end

    def destroy
      @salary_rule = SalaryRule.find(params[:id])

      @salary_rule.destroy
    end

    private

    def set_nurses_and_services
      @nurses = @corporation.nurses.displayable
      @services = @corporation.services.where(nurse_id: nil)
    end

    def salary_rules_params
      params.require(:salary_rule).permit(:title, :target_all_nurses, :target_all_services, :service_date_range_start, :service_date_range_end, :date_constraint, :expires_at, :operator, :argument, :hour_based, :target_nurse_by_filter, :one_time_salary_rule, nurse_id_list: [], service_title_list: [])
    end

end