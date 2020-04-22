class AddTeamPostsOptionToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :separate_posts_by_team, :boolean, default: true
  end
end
