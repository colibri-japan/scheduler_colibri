class AddIncludeAppointmentsAsSecondNurseToSalaryRules < ActiveRecord::Migration[5.1]
  def change
    add_column :salary_rules, :include_appointments_as_second_nurse, :boolean, default: false
  end
end
