class AddDurationToWishedSlots < ActiveRecord::Migration[5.1]
  def change
    add_column :wished_slots, :duration, :integer
  end
end
