class ChangeDefaultInsuranceCategoryForServices < ActiveRecord::Migration[5.1]
  def change
    change_column_default :services, :inside_insurance_scope, from: true, to: false 
  end
end
