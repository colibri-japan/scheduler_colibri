class RenameColumnInPosts < ActiveRecord::Migration[5.1]
  def change
    rename_column :posts, :corporations_id, :corporation_id
  end
end
