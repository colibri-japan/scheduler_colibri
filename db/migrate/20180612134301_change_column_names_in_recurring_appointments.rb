class ChangeColumnNamesInRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
  	rename_column :recurring_appointments, :start_time, :start
  	rename_column :recurring_appointments, :end_time, :end
  end
end
