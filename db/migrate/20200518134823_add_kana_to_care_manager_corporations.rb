class AddKanaToCareManagerCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :care_manager_corporations, :kana, :string
  end
end
