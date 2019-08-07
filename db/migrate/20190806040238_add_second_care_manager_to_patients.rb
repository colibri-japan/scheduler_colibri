class AddSecondCareManagerToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :second_care_manager_id, :integer, index: true
  end
end
