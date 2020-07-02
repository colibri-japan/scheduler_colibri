class AddTrainingWageToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :second_nurse_unit_wage, :integer
    add_column :services, :second_nurse_hour_based_wage, :boolean
  end
end
