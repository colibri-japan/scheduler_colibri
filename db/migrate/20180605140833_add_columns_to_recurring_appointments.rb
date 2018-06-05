class AddColumnsToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
  	add_column :recurring_appointments, :start_time, :datetime
  	add_column :recurring_appointments, :end_time, :datetime
  end
end
