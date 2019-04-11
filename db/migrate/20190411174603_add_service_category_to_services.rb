class AddServiceCategoryToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :category_1, :integer
    add_column :services, :category_2, :integer
    add_column :services, :category_ratio, :numeric
  end
end
