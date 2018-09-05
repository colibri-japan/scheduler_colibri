class AddHourBasedWageToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :hour_based_wage, :boolean, default: true
  end
end
