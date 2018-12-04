class CreatePrintingOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :printing_options do |t|
      t.references :corporation, foreign_key: true
      t.boolean :print_patient_comments, default: false
      t.boolean :print_nurse_comments, default: false
      t.boolean :print_patient_comments_in_master, default: false 
      t.boolean :print_nurse_comments_in_master, default: false 
      t.boolean :print_patient_dates, default: true 
      t.boolean :print_nurse_dates, default: true 
      t.boolean :print_patient_dates_in_master, default: true 
      t.boolean :print_nurse_dates_in_master, default: true 
      t.boolean :print_patient_description, default: false 
      t.boolean :print_nurse_description, default: false 
      t.boolean :print_patient_description_in_master, default: false 
      t.boolean :print_patient_description_in_master, default: false

      t.timestamps
    end
  end
end
