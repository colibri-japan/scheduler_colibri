class AddFieldsToRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :recurring_appointments, :color, :string
    add_column :recurring_appointments, :description, :text
  end
end
