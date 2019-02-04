class AddVerifierToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :verifier, references: :users, index: true
    add_foreign_key :provided_services, :users, column: :verifier_id
  end
end
