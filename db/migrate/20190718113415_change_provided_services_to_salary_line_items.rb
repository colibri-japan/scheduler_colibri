class ChangeSalaryLineItemsToSalaryLineItems < ActiveRecord::Migration[5.1]
  def change
    rename_table :salary_line_items, :salary_line_items
  end
end
