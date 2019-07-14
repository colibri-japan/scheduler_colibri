class RemoveCancelledAndEditRequestedFromRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :recurring_appointments, :cancelled
    remove_column :recurring_appointments, :edit_requested
  end
end
