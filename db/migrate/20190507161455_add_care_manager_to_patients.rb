class AddCareManagerToPatients < ActiveRecord::Migration[5.1]
  def change
    add_reference :patients, :care_manager, index: true
  end
end
