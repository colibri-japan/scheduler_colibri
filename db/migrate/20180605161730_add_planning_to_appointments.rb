class AddPlanningToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :planning, foreign_key: true, index: true
  end
end
