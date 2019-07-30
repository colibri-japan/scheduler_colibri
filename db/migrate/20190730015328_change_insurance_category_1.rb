class ChangeInsuranceCategory1 < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :inside_insurance_scope, :boolean, default: true
    rename_column :services, :insurance_category_2, :insurance_service_category
  end
end
