class ChangeForHolidaysInSalaryRules < ActiveRecord::Migration[5.1]
  def change
    remove_column :salary_rules, :for_holidays
    add_column :salary_rules, :holiday_operator, :integer
  end
end
