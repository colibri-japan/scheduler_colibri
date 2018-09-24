class AddInformationToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :previous_color, :string
    add_column :activities, :previous_deleted, :boolean
    add_column :activities, :previous_description, :text
    add_column :activities, :previous_title, :string
    add_column :activities, :previous_edit_requested, :boolean
    add_column :activities, :previous_duration, :integer
  end
end
