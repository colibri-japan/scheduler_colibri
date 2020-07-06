class AddPreviousSecondNurseToActivities < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :previous_second_nurse, references: :nurses, index: true
  end
end
