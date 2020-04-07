class AddEmergencyContactsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :emergency_contact_1_name, :string
    add_column :patients, :emergency_contact_1_address, :string
    add_column :patients, :emergency_contact_1_phone, :string
    add_column :patients, :emergency_contact_1_relationship, :string
    add_column :patients, :emergency_contact_1_living_with_patient, :boolean, default: false
    add_column :patients, :emergency_contact_2_name, :string
    add_column :patients, :emergency_contact_2_address, :string
    add_column :patients, :emergency_contact_2_phone, :string
    add_column :patients, :emergency_contact_2_relationship, :string
    add_column :patients, :emergency_contact_2_living_with_patient, :boolean, default: false
  end
end
