class AddColumnsToCompletionReports < ActiveRecord::Migration[5.1]
  def change
    add_column :completion_reports, :batch_assisted_bathroom, :boolean, default: false
    add_column :completion_reports, :batch_assisted_meal, :boolean, default: false
    add_column :completion_reports, :batch_assisted_bed_bath, :boolean, default: false
    add_column :completion_reports, :batch_assisted_partial_bath, :boolean, default: false
    add_column :completion_reports, :batch_assisted_total_bath, :boolean, default: false
    add_column :completion_reports, :batch_assisted_cosmetics, :boolean, default: false
    add_column :completion_reports, :batch_assisted_house_cleaning, :boolean, default: false
    add_column :completion_reports, :batch_assisted_laundry, :boolean, default: false
    add_column :completion_reports, :batch_assisted_bedmake, :boolean, default: false
    add_column :completion_reports, :batch_assisted_storing_furniture, :boolean, default: false
    add_column :completion_reports, :batch_assisted_cooking, :boolean, default: false
    add_column :completion_reports, :batch_assisted_groceries, :boolean, default: false
  end
end
