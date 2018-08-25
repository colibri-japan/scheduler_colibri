class AddColumnsToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :recurring_appointment, index: true
    add_column :appointments, :duration, :numeric, default: 0
    add_column :appointments, :edit_requested, :boolean, default: false
    add_column :appointments, :color, :string
  end
end
