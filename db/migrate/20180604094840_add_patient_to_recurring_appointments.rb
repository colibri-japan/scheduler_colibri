class AddPatientToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :recurring_appointments, :patient, index: true
  end
end
