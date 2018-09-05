class AddServiceDateToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :service_date, :date
  end
end
