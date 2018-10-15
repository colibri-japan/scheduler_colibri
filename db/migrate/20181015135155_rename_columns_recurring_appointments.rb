class RenameColumnsRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    rename_column :recurring_appointments, :start, :starts_at
    rename_column :recurring_appointments, :end, :ends_at
  end
end
