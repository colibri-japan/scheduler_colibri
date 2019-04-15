class AddInsurancePolicyToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :insurance_policy, :text, array: true, default: [], using: 'case when insurance_category is null then [] when insurance_category = 0 then [0] when insurance_category = 1 then [1] when insurance_category = 2 then [2] else [] end'
  end
end
