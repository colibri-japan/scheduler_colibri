class AddReportOptionsToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :show_before_appointment_checklist_in_report_shortcut, :boolean, default: true
    add_column :corporations, :show_after_appointment_checklist_in_report_shortcut, :boolean, default: true
  end
end
