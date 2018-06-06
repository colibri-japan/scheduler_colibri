class AddCorporationToNurses < ActiveRecord::Migration[5.1]
  def change
    add_reference :nurses, :corporation, index: true
  end
end
