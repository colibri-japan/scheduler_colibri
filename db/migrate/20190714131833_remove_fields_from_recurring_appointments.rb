class RemoveFieldsFromRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    remove_columns :recurring_appointments, :displayable
    remove_columns :recurring_appointments, :master
    remove_columns :recurring_appointments, :duplicatable
  end
end
