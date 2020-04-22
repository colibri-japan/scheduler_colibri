class AddTeamReferenceToPatients < ActiveRecord::Migration[5.1]
  def change
    add_reference :patients, :team, index: true
  end
end
