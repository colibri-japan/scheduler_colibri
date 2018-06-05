class CreateCorporations < ActiveRecord::Migration[5.1]
  def change
    create_table :corporations do |t|
      t.string :name
      t.string :address
      t.string :identifier

      t.timestamps
    end
  end
end
