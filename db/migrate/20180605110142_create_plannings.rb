class CreatePlannings < ActiveRecord::Migration[5.1]
  def change
    create_table :plannings do |t|
      t.integer :business_month
      t.integer :business_year
      t.references :corporation, index: true
      t.timestamps
    end
  end
end
