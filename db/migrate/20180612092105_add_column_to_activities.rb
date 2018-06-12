class AddColumnToActivities < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :planning, index: true
  end
end
