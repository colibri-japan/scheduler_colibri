class RenameColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :appointments, :end, :ends_at
    rename_column :appointments, :start, :starts_at
  end
end
