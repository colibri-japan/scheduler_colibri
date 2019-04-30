class AddEndOfContractToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :end_of_contract, :date
  end
end
