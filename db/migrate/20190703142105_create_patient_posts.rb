class CreatePatientPosts < ActiveRecord::Migration[5.1]
  def change
    create_table :patient_posts do |t|
      t.references :patient, foreign_key: true
      t.references :post, foreign_key: true

      t.timestamps
    end
  end
end
