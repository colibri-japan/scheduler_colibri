class CreateUnavailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :unavailabilities do |t|
      t.string :title
      t.string :description
      t.datetime :start
      t.datetime :end
      t.references :nurse, index: true
      t.references :planning, index: true

      t.timestamps
    end
  end
end
