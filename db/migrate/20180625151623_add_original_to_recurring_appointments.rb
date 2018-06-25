class AddOriginalToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :recurring_appointments, :original, references: :recurring_appointments, index: true
  end
end
