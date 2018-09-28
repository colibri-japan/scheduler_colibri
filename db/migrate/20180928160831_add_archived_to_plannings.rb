class AddArchivedToPlannings < ActiveRecord::Migration[5.1]
  def change
    add_column :plannings, :archived, :boolean, default: false
  end
end
