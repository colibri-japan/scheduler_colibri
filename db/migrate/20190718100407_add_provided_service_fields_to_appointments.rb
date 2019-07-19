class AddProvidedServiceFieldsToAppointments < ActiveRecord::Migration[5.1]
  def change
    add_column :appointments, :total_credits, :integer
    add_column :appointments, :total_invoiced, :integer
    add_column :appointments, :total_wage, :integer
    add_column :appointments, :verified_at, :datetime
    add_reference :appointments, :verifier, references: :users, index: true
    add_column :appointments, :second_verified_at, :datetime
    add_reference :appointments, :second_verifier, references: :users, index: true
  end
end
