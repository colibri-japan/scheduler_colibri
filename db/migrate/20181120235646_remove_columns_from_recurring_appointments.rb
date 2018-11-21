class RemoveColumnsFromRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :recurring_appointments, :deleted
  end
end
