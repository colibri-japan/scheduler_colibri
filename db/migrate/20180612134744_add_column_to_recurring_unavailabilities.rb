class AddColumnToRecurringUnavailabilities < ActiveRecord::Migration[5.1]
  def change
    add_reference :recurring_unavailabilities, :patient, index: true
  end
end
