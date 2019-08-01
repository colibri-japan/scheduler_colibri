class AddArchivedAtToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :archived_at, :timestamp
  end
end
