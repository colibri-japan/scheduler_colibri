class CreateProvidedServices < ActiveRecord::Migration[5.1]
  def change
    create_table :provided_services do |t|
      t.references :payable, polymorphic: true, index: true
      t.integer :hourly_wage
      t.integer :service_duration
      t.integer :total_wage

      t.timestamps
    end
  end
end
