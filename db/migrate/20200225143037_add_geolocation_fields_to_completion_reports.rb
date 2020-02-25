class AddGeolocationFieldsToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :accuracy, :decimal
    add_column :completion_reports, :altitude, :decimal 
    add_column :completion_reports, :altitude_accuracy, :decimal
  end
end
