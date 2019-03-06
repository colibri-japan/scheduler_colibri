class RenameRecurringUnavailabilitiesToWishedSlots < ActiveRecord::Migration[5.1]
  def change
    rename_table :recurring_unavailabilities, :wished_slots
  end
end
