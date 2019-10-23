class ChangeAppointmentsIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :appointments, [:starts_at, :nurse_id, :patient_id]
  end
end
