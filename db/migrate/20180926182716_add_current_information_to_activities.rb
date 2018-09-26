class AddCurrentInformationToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :new_start, :datetime
    add_column :activities, :new_end, :datetime
    add_column :activities, :new_anchor, :date
    add_column :activities, :new_nurse, :string
    add_column :activities, :new_patient, :string
    add_column :activities, :new_title, :string
    add_column :activities, :new_color, :string
    add_column :activities, :new_edit_requested, :boolean
  end
end
