class FixColumnNamesProvidedServices < ActiveRecord::Migration[5.1]
  def change
    rename_column :provided_services, :deactivated, :cancelled
  end
end
