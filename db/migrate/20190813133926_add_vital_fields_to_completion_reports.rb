class AddVitalFieldsToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :heart_rate_bpm, :integer
    add_column :completion_reports, :heart_rythm_anomalies, :integer 
    add_column :completion_reports, :blood_sugar, :integer 
    add_column :completion_reports, :blood_oxygen_rate, :integer 
    add_column :completion_reports, :breathe_rate, :integer 
    add_column :completion_reports, :body_weight, :integer
  end
end
