class AddStartAndEndToCarePlans < ActiveRecord::Migration[5.1]
  def change
    add_column :care_plans, :short_term_goals_start_date, :date
    add_column :care_plans, :long_term_goals_start_date, :date
    add_column :care_plans, :long_term_goals_due_date, :date
  end
end
