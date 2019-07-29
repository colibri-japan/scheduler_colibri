class AddMonthlyWageToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :monthly_wage, :integer
  end
end
