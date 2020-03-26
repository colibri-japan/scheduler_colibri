class AddMeetingInfoToCarePlans < ActiveRecord::Migration[5.1]
  def change
    add_column :care_plans, :meeting_date, :date 
    add_reference :care_plans, :attending_nurse, references: :nurses, index: true
  end
end
