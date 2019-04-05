class RemoveInvoiceSettings < ActiveRecord::Migration[5.1]
  def change
    remove_column :provided_services, :invoice_setting_id
    drop_table :invoice_setting_nurses
    drop_table :invoice_setting_services
    drop_table :invoice_settings
  end
end
