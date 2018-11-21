class RenameColumnsAppointments < ActiveRecord::Migration[5.1]
  def change
    rename_column :appointments, :deactivated, :cancelled
    rename_column :appointments, :deleted_at, :archived_at
  end
end
