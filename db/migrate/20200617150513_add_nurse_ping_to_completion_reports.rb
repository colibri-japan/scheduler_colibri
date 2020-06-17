class AddNursePingToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :nurse_ping, :boolean, default: false
  end
end
