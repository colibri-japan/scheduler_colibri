class AddDefaultFirstDayToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :default_first_day, :integer, default: 1
  end
end
