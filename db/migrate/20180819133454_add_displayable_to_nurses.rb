class AddDisplayableToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :displayable, :boolean, default: true
  end
end
