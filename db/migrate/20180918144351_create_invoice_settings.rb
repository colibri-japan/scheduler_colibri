class CreateInvoiceSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :invoice_settings do |t|
      t.references :corporation, foreign_key: true
      t.string :title
      t.integer :target_services_by_1
      t.integer :target_services_by_2
      t.integer :target_services_by_3
      t.integer :invoice_line_option
      t.integer :operator
      t.numeric :argument
      t.boolean :hour_based

      t.timestamps
    end
  end
end
