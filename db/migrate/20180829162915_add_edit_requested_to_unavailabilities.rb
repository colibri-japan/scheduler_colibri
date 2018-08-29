class AddEditRequestedToUnavailabilities < ActiveRecord::Migration[5.1]
  def change
    add_column :unavailabilities, :edit_requested, :boolean, default: false
  end
end
