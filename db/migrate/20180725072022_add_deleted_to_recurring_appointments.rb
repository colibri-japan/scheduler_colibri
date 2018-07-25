class AddDeletedToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :deleted, :boolean
    add_column :recurring_appointments, :deleted_at, :datetime
  end
end
