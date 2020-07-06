class AddSecondNurseToActivities < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :second_nurse, references: :nurses, index: true
  end
end
