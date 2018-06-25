class AddMasterToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :master, :boolean
    add_column :appointments, :displayable, :boolean
  end
end
