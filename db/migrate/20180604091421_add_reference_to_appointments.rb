class AddReferenceToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :nurse, index: true
  end
end
