class AddFieldsToCarePlans < ActiveRecord::Migration[5.1]
  def change
    add_column :care_plans, :short_term_goals, :text
    add_column :care_plans, :long_term_goals, :text
    add_column :care_plans, :patient_wishes, :text
    add_column :care_plans, :family_wishes, :text
    add_reference :care_plans, :second_care_manager, references: :care_managers
  end
end
