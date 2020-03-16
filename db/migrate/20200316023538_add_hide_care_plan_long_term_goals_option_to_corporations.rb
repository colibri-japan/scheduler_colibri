class AddHideCarePlanLongTermGoalsOptionToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :hide_care_plan_long_term_goals, :boolean, default: :false
  end
end
