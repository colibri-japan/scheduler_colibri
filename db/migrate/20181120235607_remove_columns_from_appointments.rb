class RemoveColumnsFromAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_column :appointments, :deleted
  end
end
