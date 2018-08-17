class AddEditRequestedToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :edit_requested, :boolean, default: false
  end
end
