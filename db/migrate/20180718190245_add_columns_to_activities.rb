class AddColumnsToActivities < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :nurse, index: true
    add_reference :activities, :patient, index: true
  end
end
