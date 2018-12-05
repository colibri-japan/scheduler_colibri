class AddReferenceToNurses < ActiveRecord::Migration[5.1]
  def change
    add_reference :nurses, :team, index: true
  end
end
