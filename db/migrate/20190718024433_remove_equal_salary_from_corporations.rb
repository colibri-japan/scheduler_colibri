class RemoveEqualSalaryFromCorporations < ActiveRecord::Migration[5.1]
  def change
    remove_column :corporations, :equal_salary
  end
end
