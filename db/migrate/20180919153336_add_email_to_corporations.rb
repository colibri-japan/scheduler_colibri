class AddEmailToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :email, :string
  end
end
