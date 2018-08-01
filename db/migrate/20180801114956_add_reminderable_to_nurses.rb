class AddReminderableToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :reminderable, :boolean, default: false
  end
end
