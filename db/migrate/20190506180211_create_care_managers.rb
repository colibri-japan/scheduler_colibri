class CreateCareManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :care_managers do |t|
      t.string :name 
      t.string :kana
      t.references :care_manager_corporation, index: true
      t.string :registration_id
      t.text :description

      t.timestamps
    end
  end
end
