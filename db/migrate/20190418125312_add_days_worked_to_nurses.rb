class AddDaysWorkedToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :days_worked, :integer, default: 0
  end
end
