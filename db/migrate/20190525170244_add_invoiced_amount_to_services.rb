class AddInvoicedAmountToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :invoiced_amount, :integer
  end
end
