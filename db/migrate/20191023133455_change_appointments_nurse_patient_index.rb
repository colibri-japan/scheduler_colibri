class ChangeAppointmentsNursePatientIndex < ActiveRecord::Migration[5.1]
  def change
    remove_index "appointments", name: "index_appointments_on_starts_at_and_nurse_id_and_patient_id"
    add_index :appointments, [:starts_at, :nurse_id]
    add_index :appointments, [:starts_at, :patient_id]
  end
end
