class ChangeColumnProvidedServices < ActiveRecord::Migration[5.1]
  def change
    change_column :provided_services, :service_date, :datetime
  end
end
