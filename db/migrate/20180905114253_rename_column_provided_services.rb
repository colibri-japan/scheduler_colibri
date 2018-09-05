class RenameColumnProvidedServices < ActiveRecord::Migration[5.1]
  def change
    rename_column :provided_services, :hourly_wage, :unit_cost
  end
end
