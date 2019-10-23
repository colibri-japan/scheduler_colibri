class AddIndexToPrivateEvents < ActiveRecord::Migration[5.1]
  def change
    add_index :private_events, [:planning_id, :starts_at, :ends_at]
    add_index :private_events, [:nurse_id, :starts_at, :ends_at]
    add_index :private_events, [:patient_id, :starts_at, :ends_at]
  end
end
