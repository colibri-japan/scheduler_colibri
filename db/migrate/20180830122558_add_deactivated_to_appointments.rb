class AddDeactivatedToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :deactivated, :boolean, default: false
  end
end
