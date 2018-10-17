class AddServiceToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :service_salary, references: :services, index: true
  end
end
