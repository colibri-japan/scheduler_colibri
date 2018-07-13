class AddFieldsToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :previous_patient, :string
    add_column :activities, :previous_nurse, :string
    add_column :activities, :previous_start, :datetime
    add_column :activities, :previous_end, :datetime
    add_column :activities, :previous_anchor, :date
  end
end
