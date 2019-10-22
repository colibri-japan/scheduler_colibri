class AddIndexToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_index :recurring_appointments, [:planning_id, :termination_date], name: 'index_recurring_planning_termination'
  end
end
