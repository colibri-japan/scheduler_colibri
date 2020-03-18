class AddTimestampsToCarePlans < ActiveRecord::Migration[5.1]
  def change
    add_column :care_plans, :created_at, :datetime, null: false, default: Time.zone.now
    add_column :care_plans, :updated_at, :datetime, null: false, default: Time.zone.now
    add_column :care_plans, :creation_date, :date
  end
end
