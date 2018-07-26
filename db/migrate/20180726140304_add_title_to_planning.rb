class AddTitleToPlanning < ActiveRecord::Migration[5.1]
  def change
    add_column :plannings, :title, :string
  end
end
