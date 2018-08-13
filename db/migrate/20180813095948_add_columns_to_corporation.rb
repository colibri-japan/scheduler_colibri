class AddColumnsToCorporation < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :business_start_hour, :string, default: "07:00:00"
    add_column :corporations, :business_end_hour, :string, default: "24:00:00"
  end
end
