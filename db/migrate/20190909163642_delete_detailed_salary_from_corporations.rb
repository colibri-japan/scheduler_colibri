class DeleteDetailedSalaryFromCorporations < ActiveRecord::Migration[5.1]
  def change
    remove_column :corporations, :detailed_salary
  end
end
