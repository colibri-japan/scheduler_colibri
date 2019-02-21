class AddFieldsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :care_manager_name, :string
    add_column :patients, :doctor_name, :string
    add_column :patients, :insurance_category, :boolean
    add_column :patients, :kaigo_level, :integer
    add_column :patients, :date_of_contract, :date
    add_reference :patients, :nurse, index: true
  end
end
