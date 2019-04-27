class AddCreditsToJpyRatioToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :credits_to_jpy_ratio, :numeric
  end
end
