class AddAppointmentComparisonFields < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :changed_datetime, :boolean, default: false
    add_column :appointments, :spot_appointment, :boolean, default: false
  end
end
