class CreateInvoiceSettingNurses < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_setting_nurses do |t|
      t.references :invoice_setting, foreign_key: true
      t.references :nurse, foreign_key: true

      t.timestamps
    end
  end
end
