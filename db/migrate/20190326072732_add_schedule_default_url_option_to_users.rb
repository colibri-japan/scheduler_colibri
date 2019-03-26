class AddScheduleDefaultUrlOptionToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :schedule_default_url_option, :string
  end
end
