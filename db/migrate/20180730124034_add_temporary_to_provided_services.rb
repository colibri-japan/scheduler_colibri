class AddTemporaryToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :temporary, :boolean, default: false, null: false
  end
end
