class AddReferencesToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_reference :completion_reports, :planning, index: true
    add_reference :completion_reports, :patient, index: true
  end
end
