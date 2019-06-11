class AddFaxNumbers < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :fax_number, :string
    add_column :teams, :fax_number, :string
  end
end
