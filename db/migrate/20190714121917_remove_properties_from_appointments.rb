class RemovePropertiesFromAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :appointments, :displayable
    remove_column :appointments, :master
  end
end
