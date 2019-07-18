class FixReferencesInNurseServiceWage < ActiveRecord::Migration[5.1]
  def change
    remove_column :nurse_service_wages, :nurses_id
    remove_column :nurse_service_wages, :services_id
    add_reference :nurse_service_wages, :nurse, index: true
    add_reference :nurse_service_wages, :service, index: true
  end
end
