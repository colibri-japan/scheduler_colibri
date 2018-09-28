class AddColumnsToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :unit_wage, :integer
    add_column :services, :weekend_unit_wage, :numeric
    add_reference :services, :nurse, index: true
  end
end
