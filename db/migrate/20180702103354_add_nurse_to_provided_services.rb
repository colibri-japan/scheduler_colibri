class AddNurseToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :nurse, index: true
  end
end
