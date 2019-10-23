class AddIndexedToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_index :recurring_appointments, [:nurse_id, :termination_date]
    add_index :recurring_appointments, [:patient_id, :termination_date]
  end
end
