class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.references :corporation, foreign_key: true
      t.string :team_name

      t.timestamps
    end
  end
end
