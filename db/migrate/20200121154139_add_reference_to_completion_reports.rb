class AddReferenceToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_reference :completion_reports, :forecasted_report, index: true
  end
end
