class AddTeikyohyoFieldsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :issuing_administration_number, :string
    add_column :patients, :issuing_administration_name, :string
    add_column :patients, :previous_kaigo_level, :integer
  end
end
