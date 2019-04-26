class AddInvoicingFieldsToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_column :provided_services, :total_credits, :integer
    add_column :provided_services, :invoiced_total, :integer
  end
end
