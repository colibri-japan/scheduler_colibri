class ModifyInsuranceCategory < ActiveRecord::Migration[5.1]
  def change
    change_column :patients, :insurance_category, :integer, using: 'case when insurance_category is null then null when insurance_category then 0 else 1 end'
  end
end
