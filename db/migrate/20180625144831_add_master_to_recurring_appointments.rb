class AddMasterToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :master, :boolean
    add_column :recurring_appointments, :displayable, :boolean
  end
end
