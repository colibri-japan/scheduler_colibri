class AddTerminationDateToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :termination_date, :datetime
  end
end
