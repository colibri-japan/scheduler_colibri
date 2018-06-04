class AddReferenceToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :recurring_appointments, :nurse, index: true
  end
end
