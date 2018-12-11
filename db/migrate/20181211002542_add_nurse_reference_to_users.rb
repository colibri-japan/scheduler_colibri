class AddNurseReferenceToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :nurse, index: true
  end
end
