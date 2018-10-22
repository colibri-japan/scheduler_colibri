class AddDescriptionToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :description, :text
  end
end
