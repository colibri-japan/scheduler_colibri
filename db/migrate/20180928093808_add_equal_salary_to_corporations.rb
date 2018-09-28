class AddEqualSalaryToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :equal_salary, :boolean
  end
end
