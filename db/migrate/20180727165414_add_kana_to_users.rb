class AddKanaToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :kana, :string
  end
end
