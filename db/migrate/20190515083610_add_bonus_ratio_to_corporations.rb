class AddBonusRatioToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :invoicing_bonus_ratio, :numeric, default: 1
    add_column :corporations, :invoicing_bonus_ratio_start_date, :date
    add_column :corporations, :previous_invoicing_bonus_ratio, :numeric
  end
end
