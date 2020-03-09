class CreateCarePlan < ActiveRecord::Migration[5.1]
  def change
    create_table :care_plans do |t|
      t.references :patient, index: true
      t.references :care_manager, index: true
      t.date :kaigo_certification_validity_start
      t.date :kaigo_certification_validity_end
      t.date :kaigo_certification_date
      t.integer :insurance_category
      t.integer :kaigo_level
      t.integer :handicap_level
    end 
  end
end
