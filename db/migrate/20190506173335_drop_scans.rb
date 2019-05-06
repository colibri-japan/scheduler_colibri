class DropScans < ActiveRecord::Migration[5.1]
  def change
    drop_table :scans
  end
end
