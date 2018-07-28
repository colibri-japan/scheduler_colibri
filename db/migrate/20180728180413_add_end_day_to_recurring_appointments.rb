class AddEndDayToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :end_day, :date
    add_column :recurring_appointments, :duration, :numeric
  end
end
