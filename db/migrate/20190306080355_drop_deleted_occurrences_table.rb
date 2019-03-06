class DropDeletedOccurrencesTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :deleted_occurrences
  end
end
