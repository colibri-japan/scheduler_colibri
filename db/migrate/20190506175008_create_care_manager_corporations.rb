class CreateCareManagerCorporations < ActiveRecord::Migration[5.1]
  def change
    create_table :care_manager_corporations do |t|
      t.string :name
      t.string :address 
      t.string :phone_number
      t.text :description

      t.timestamps
    end
  end
end
