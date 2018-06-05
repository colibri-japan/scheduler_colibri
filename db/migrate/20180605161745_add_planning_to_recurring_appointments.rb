class AddPlanningToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :recurring_appointments, :planning, foreign_key: true, index: true
  end
end
