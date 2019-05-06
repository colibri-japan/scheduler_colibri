class AddReferenceToCareManagerCorporations < ActiveRecord::Migration[5.1]
  def change
    add_reference :care_manager_corporations, :corporation, foreign_key: true
  end
end
