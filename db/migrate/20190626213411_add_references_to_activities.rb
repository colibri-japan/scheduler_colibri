class AddReferencesToActivities < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :previous_patient, references: :patients, index: true
    add_reference :activities, :previous_nurse, references: :nurses, index: true
    rename_column :activities, :previous_nurse, :previous_nurse_name
    rename_column :activities, :previous_patient, :previous_patient_name
    rename_column :activities, :new_nurse, :nurse_name
    rename_column :activities, :new_patient, :patient_name
  end
end
