class AddBirthdayEraToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :birthday_era, :string
  end
end
