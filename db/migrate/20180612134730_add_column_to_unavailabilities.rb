class AddColumnToUnavailabilities < ActiveRecord::Migration[5.1]
  def change
    add_reference :unavailabilities, :patient, index: true
  end
end
