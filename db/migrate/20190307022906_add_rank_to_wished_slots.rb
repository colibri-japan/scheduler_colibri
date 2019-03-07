class AddRankToWishedSlots < ActiveRecord::Migration[5.1]
  def change
    add_column :wished_slots, :rank, :integer
  end
end
