class AddGenderToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :gender, :boolean, default: true
  end
end
