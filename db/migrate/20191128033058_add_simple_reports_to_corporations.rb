class AddSimpleReportsToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :simple_reports, :boolean, default: false
  end
end
