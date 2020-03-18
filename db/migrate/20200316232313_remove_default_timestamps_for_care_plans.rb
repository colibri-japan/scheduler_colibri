class RemoveDefaultTimestampsForCarePlans < ActiveRecord::Migration[5.1]
  def change
    change_column_default :care_plans, :created_at, nil
    change_column_default :care_plans, :updated_at, nil
  end
end
