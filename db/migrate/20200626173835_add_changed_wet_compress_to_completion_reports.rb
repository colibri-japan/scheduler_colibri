class AddChangedWetCompressToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :changed_wet_compress, :boolean
  end
end
