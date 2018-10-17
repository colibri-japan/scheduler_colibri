class AddServiceToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :service, index: true
  end
end
