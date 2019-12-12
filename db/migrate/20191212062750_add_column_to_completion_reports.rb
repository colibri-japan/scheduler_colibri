class AddColumnToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :watched_after_patient_safety_doing, :text, array: true, default: []
  end
end
