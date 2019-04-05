class AddHourBasedToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :hour_based, :boolean
  end
end
