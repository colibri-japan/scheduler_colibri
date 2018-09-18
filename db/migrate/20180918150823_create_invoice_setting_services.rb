class CreateInvoiceSettingServices < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_setting_services do |t|
      t.references :invoice_setting, foreign_key: true
      t.references :service, foreign_key: true

      t.timestamps
    end
  end
end
