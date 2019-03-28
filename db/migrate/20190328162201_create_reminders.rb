class CreateReminders < ActiveRecord::Migration[5.1]
  def change
    create_table :reminders do |t|
      t.datetime :anchor
      t.integer :frequency
      t.references :reminderable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
