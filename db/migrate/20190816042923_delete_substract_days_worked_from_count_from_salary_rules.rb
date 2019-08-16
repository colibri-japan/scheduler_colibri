class DeleteSubstractDaysWorkedFromCountFromSalaryRules < ActiveRecord::Migration[5.1]
  def change
    remove_column :salary_rules, :substract_days_worked_from_count
  end
end
