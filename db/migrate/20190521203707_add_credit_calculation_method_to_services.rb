class AddCreditCalculationMethodToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :credit_calculation_method, :integer, default: 0
  end
end
