class ChangeColumnRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    change_column :recurring_appointments, :duration, :integer
  end
end
