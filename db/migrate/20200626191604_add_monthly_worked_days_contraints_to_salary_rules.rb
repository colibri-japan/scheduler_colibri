class AddMonthlyWorkedDaysContraintsToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :min_monthly_days_worked, :integer
    add_column :salary_rules, :max_monthly_days_worked, :integer
  end
end
