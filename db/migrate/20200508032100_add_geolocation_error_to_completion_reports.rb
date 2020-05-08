class AddGeolocationErrorToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :geolocation_error_code, :integer
    add_column :completion_reports, :geolocation_error_message, :string
  end
end
