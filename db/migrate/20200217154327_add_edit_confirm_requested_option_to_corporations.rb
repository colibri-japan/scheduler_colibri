class AddEditConfirmRequestedOptionToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :edit_confirm_requested, :boolean, default: :true
  end
end
