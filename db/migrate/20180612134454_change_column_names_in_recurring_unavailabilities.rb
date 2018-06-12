class ChangeColumnNamesInRecurringUnavailabilities < ActiveRecord::Migration[5.1]
  def change
  	rename_column :recurring_unavailabilities, :start_time, :start
  	rename_column :recurring_unavailabilities, :end_time, :end
  end
end
