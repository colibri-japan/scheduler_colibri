class RenameColumnsRecurringUnavailabilities < ActiveRecord::Migration[5.1]
  def change
    rename_column :recurring_unavailabilities, :start, :starts_at
    rename_column :recurring_unavailabilities, :end, :ends_at
  end
end
