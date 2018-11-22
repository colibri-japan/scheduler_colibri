class AddPreviousCancelledToActivities < ActiveRecord::Migration[5.1]
  def change
    add_column :activities, :previous_cancelled, :boolean
  end
end
