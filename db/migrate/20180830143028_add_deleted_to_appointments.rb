class AddDeletedToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :deleted, :boolean, default: false
    add_column :appointments, :deleted_at, :datetime
  end
end
