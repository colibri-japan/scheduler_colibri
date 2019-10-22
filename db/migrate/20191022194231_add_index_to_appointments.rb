class AddIndexToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_index :appointments, [:starts_at, :planning_id]
  end
end
