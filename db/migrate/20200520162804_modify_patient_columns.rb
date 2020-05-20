class ModifyPatientColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :zip_code, :string
  end
end
