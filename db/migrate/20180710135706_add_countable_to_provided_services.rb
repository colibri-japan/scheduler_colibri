class AddCountableToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :countable, :boolean
  end
end
