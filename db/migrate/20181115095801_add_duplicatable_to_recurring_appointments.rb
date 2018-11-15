class AddDuplicatableToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :duplicatable, :boolean, default: true
  end
end
