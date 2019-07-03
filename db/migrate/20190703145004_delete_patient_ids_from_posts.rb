class DeletePatientIdsFromPosts < ActiveRecord::Migration[5.1]
  def change
    remove_column :posts, :patient_ids
  end
end
