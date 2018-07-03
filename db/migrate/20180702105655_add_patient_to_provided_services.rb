class AddPatientToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :patient, index: true
  end
end
