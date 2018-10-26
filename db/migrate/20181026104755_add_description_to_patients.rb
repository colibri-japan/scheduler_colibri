class AddDescriptionToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :description, :text
  end
end
