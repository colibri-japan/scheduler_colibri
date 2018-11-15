class AddReminderEmailHourToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :reminder_email_hour, :string, default: '11:00'
    add_column :corporations, :weekend_reminder_option, :integer, default: 0
  end
end
