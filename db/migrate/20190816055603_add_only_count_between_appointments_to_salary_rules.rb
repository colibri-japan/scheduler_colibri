class AddOnlyCountBetweenAppointmentsToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :only_count_between_appointments, :boolean, default: false
  end
end
