class AddTargetingFieldsToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :substract_days_worked_from_count, :boolean, default: false 
    add_column :salary_rules, :min_days_worked, :integer
    add_column :salary_rules, :max_days_worked, :integer 
    add_column :salary_rules, :min_months_worked, :integer
    add_column :salary_rules, :max_months_worked, :integer
  end
end
