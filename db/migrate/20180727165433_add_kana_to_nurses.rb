class AddKanaToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :kana, :string
  end
end
