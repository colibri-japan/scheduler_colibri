class AddKanaToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :kana, :string
  end
end
