class AddCareInstructionsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :care_instructions, :text
  end
end
