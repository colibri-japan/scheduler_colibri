class AddDetailedSalaryToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :detailed_salary, :boolean, default: false
  end
end
