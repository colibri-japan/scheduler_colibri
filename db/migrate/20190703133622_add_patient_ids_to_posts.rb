class AddPatientIdsToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :patient_ids, :text, array: true, default: []
  end
end
