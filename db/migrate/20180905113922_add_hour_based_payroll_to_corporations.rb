class AddHourBasedPayrollToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :hour_based_payroll, :boolean, default: true
  end
end
