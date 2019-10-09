class AddOriginalRecurringAppointmentToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :original_recurring_appointment, references: :recurring_appointments, index: true
  end
end
