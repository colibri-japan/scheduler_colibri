class CreateNurseServiceWages < ActiveRecord::Migration[5.1]
  def change
    create_table :nurse_service_wages do |t|
      t.references :nurses, index: true, foreign_key: true 
      t.references :services, index: true, foreign_key: true
      t.integer :unit_wage
      t.integer :weekend_unit_wage
      t.timestamps
    end
  end
end
