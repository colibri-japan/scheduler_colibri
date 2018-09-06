class AddColumnsToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :appointment_start, :datetime
    add_column :provided_services, :appointment_end, :datetime
  end
end
