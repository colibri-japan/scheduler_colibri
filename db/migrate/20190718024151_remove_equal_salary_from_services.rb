class RemoveEqualSalaryFromServices < ActiveRecord::Migration[5.1]
  def change
    remove_column :services, :equal_salary
  end
end
