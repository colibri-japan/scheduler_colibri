class FixColumnNamesRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    rename_column :recurring_appointments, :deactivated, :cancelled
    rename_column :recurring_appointments, :deleted_at, :archived_at
  end
end
