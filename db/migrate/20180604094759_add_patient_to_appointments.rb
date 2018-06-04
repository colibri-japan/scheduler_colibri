class AddPatientToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :patient, index: true
  end
end
