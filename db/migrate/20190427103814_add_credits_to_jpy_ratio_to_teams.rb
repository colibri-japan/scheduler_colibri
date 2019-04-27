class AddCreditsToJpyRatioToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :credits_to_jpy_ratio, :numeric
  end
end
