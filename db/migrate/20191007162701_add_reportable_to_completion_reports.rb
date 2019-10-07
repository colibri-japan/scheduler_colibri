class AddReportableToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_reference :completion_reports, :reportable, polymorphic: true, index: true
  end
end
