class AddSecondVerifierToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :second_verifier, references: :users, index: true
    add_foreign_key :provided_services, :users, column: :second_verifier_id
    add_column :provided_services, :second_verified_at, :timestamp
  end
end
