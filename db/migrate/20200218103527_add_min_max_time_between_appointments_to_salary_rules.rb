class AddMinMaxTimeBetweenAppointmentsToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :min_time_between_appointments, :integer
    add_column :salary_rules, :max_time_between_appointments, :integer
  end
end
