class AddContractDateToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :contract_date, :date
  end
end
