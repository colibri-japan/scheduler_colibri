class AddSecondNurseToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_reference :appointments, :second_nurse, references: :nurses, index: true
    add_column :appointments, :second_nurse_wage, :integer
  end
end
