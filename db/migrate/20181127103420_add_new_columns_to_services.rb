class AddNewColumnsToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :hour_based_wage, :boolean
    add_column :services, :equal_salary, :boolean
  end
end
