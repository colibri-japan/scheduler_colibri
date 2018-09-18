class AddInvoiceSettingToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :invoice_setting, index: true
  end
end
