class AddWdayAndTimeConstraintsToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :for_holidays, :boolean, default: :false
    add_column :salary_rules, :targeted_wdays, :text, array: true, default: []
    add_column :salary_rules, :targeted_start_time, :string
    add_column :salary_rules, :targeted_end_time, :string
    add_column :salary_rules, :time_constraint_operator, :integer
  end
end
