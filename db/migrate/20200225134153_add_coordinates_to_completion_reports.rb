class AddCoordinatesToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :latitude, :decimal
    add_column :completion_reports, :longitude, :decimal
  end
end
