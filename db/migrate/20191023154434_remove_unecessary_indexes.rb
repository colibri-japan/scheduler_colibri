class RemoveUnecessaryIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index "private_events", name: "index_private_events_on_nurse_id"
    remove_index "private_events", name: "index_private_events_on_patient_id"
    remove_index "private_events", name: "index_private_events_on_planning_id"
  end
end
