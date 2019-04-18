class AddTargetNurseByFilterToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :target_nurse_by_filter, :integer
  end
end
