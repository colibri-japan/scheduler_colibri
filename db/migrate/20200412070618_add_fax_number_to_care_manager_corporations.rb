class AddFaxNumberToCareManagerCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :care_manager_corporations, :fax_number, :string
  end
end
