class AddInsuranceCategoryToServices < ActiveRecord::Migration[5.1]
  def change
    add_column :services, :insurance_category_1, :integer, default: 0
    add_column :services, :insurance_category_2, :integer
  end
end
