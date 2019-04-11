class AddHandicapLevelToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :handicap_level, :integer
  end
end
