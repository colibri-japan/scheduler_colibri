class AddBusinessVerticalToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :business_vertical, :integer, default: 0
  end
end
