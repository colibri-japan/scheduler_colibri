class AddInvoicingFieldsToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :public_assistance_receiver_number_1, :string
    add_column :patients, :public_assistance_receiver_number_2, :string
  end
end
