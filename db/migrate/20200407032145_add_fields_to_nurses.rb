class AddFieldsToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :home_phone_number, :string
    add_column :nurses, :birthday, :date
  end
end
