class AddOriginalToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :original, references: :appointments, index: true
  end
end
