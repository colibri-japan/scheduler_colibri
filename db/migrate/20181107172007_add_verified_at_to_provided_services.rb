class AddVerifiedAtToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :verified_at, :timestamp
  end
end
