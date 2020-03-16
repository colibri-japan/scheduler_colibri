class AddShortTermGoalValidityToCarePlans < ActiveRecord::Migration[5.1]
  def change
    add_column :care_plans, :short_term_goals_due_date, :date
  end
end
