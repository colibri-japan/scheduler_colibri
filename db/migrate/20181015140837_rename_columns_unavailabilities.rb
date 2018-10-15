class RenameColumnsUnavailabilities < ActiveRecord::Migration[5.1]
  def change
    rename_column :unavailabilities, :start, :starts_at
    rename_column :unavailabilities, :end, :ends_at
  end
end
