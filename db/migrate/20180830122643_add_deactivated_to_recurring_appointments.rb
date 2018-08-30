class AddDeactivatedToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :deactivated, :boolean, default: false
  end
end
