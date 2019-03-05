class RenameUnavailabilitiesToPrivateEvents < ActiveRecord::Migration[5.1]
  def change
    rename_table :unavailabilities, :private_events
  end
end
