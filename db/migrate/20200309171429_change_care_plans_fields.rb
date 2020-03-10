class ChangeCarePlansFields < ActiveRecord::Migration[5.1]
  def change
    remove_column :care_plans, :insurance_category
    add_column :care_plans, :insurance_policy, :text, array: true, default: []
  end
end
