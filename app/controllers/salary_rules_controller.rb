class SalaryRulesController < ApplicationController
    before_action :set_corporation

    def index
      set_planning
      set_main_nurse
      
      @salary_rules = @corporation.salary_rules.not_expired_at(Time.current)
    end

    def new 
      authorize current_user, :has_admin_access?
      
      set_nurses_and_services
      
      @salary_rule = @corporation.salary_rules.new
    end
    
    def create 
      authorize current_user, :has_admin_access?
      
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
      authorize current_user, :has_admin_access?
      
      set_nurses_and_services
      @salary_rule = SalaryRule.find(params[:id])
    end
    
    def update  
      authorize current_user, :has_admin_access?
      @salary_rule = SalaryRule.find(params[:id])
      
      @salary_rule.update(salary_rules_params)
    end
    
    def destroy
      authorize current_user, :has_admin_access?
      @salary_rule = SalaryRule.find(params[:id])

      @salary_rule.destroy
    end

    private

    def set_nurses_and_services
      @nurses = @corporation.nurses.displayable
      @services = @corporation.services.where(nurse_id: nil)
    end

    def salary_rules_params
      params.require(:salary_rule).permit(:title, :target_all_nurses, :target_all_services, :service_date, :date_constraint, :expires_at, :operator, :argument, :target_nurse_by_filter, :one_time_salary_rule, :min_days_worked, :max_days_worked, :min_months_worked, :max_months_worked, :substract_days_worked_from_count, :only_count_days_inside_insurance_scope, :only_count_between_appointments, :min_monthly_service_count, :max_monthly_service_count, :min_monthly_hours_worked, :max_monthly_hours_worked, :include_bonuses, :min_time_between_appointments, :max_time_between_appointments, :for_holidays, :targeted_start_time, :targeted_end_time, :time_constraint_operator, targeted_wdays: [], nurse_id_list: [], service_title_list: [])
    end

end