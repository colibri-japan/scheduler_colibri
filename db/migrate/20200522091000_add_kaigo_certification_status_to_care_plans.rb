class AddKaigoCertificationStatusToCarePlans < ActiveRecord::Migration[5.1]
  def change
    add_column :care_plans, :kaigo_certification_status, :integer, default: 2
  end
end
