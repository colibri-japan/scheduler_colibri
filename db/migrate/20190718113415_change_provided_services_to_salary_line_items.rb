class ChangeProvidedServicesToSalaryLineItems < ActiveRecord::Migration[5.1]
  def change
    rename_table :provided_services, :salary_line_items
  end
end
