class AddColumnsToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :custom_email_intro_text, :text
    add_column :corporations, :custom_email_outro_text, :text
  end
end
