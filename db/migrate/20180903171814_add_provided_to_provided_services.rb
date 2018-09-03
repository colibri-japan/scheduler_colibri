class AddProvidedToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :provided, :boolean, default: false
    add_column :provided_services, :deactivated, :boolean, default: false
  end
end
