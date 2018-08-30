class AddActiveToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :active, :boolean, default: true
    add_column :patients, :toggled_active_at, :datetime
  end
end
