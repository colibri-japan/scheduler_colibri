class AddCalendarDefaultsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :default_resource_type, :string
    add_column :users, :default_resource_id, :string
  end
end
