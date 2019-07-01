class AddAvailabilitiesDefaultTextToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :availabilities_default_text, :text
  end
end
