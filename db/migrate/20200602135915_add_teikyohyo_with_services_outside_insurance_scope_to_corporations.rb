class AddTeikyohyoWithServicesOutsideInsuranceScopeToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :teikyohyo_with_services_outside_insurance_scope, :boolean, default: false
  end
end
