class AddAppointmentToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :appointment, index: {unique: true}
  end
end
