class ChangeColumnsForWishedSlots < ActiveRecord::Migration[5.1]
  def change
    remove_column :wished_slots, :patient_id
    add_column :wished_slots, :description, :text
    add_column :wished_slots, :end_day, :date
  end
end
