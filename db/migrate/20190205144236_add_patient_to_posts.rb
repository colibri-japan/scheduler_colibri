class AddPatientToPosts < ActiveRecord::Migration[5.1]
  def change
    add_reference :posts, :patient, index: true
  end
end
