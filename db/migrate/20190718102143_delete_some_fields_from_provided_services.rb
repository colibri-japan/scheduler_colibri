class DeleteSomeFieldsFromProvidedServices < ActiveRecord::Migration[5.1]
  def change
    remove_column :provided_services, :temporary
    remove_column :provided_services, :countable
    remove_column :provided_services, :payable_type
    remove_column :provided_services, :payable_id
    remove_column :provided_services, :appointment_start
    remove_column :provided_services, :appointment_end
    remove_column :provided_services, :cancelled
  end
end
