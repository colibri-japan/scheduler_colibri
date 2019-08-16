class AddOnlyCountDaysInsideInsuranceScopeToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :only_count_days_inside_insurance_scope, :boolean, default: false
  end
end
