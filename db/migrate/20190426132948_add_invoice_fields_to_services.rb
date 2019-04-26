class AddInvoiceFieldsToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :official_title, :string
    add_column :services, :unit_credits, :integer
    add_column :services, :service_code, :string
  end
end
