class AddServiceToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :recurring_appointments, :service, index: true
  end
end
