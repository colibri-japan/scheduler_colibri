class AddMinimumWageToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :minimum_wage, :integer
  end
end
