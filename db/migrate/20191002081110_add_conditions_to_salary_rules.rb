class AddConditionsToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :min_monthly_service_count, :integer
    add_column :salary_rules, :max_monthly_service_count, :integer
    add_column :salary_rules, :min_monthly_hours_worked, :integer
    add_column :salary_rules, :max_monthly_hours_worked, :integer
  end
end
