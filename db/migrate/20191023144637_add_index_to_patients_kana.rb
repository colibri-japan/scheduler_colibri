class AddIndexToPatientsKana < ActiveRecord::Migration[5.1]
  def change
    add_index :patients, [:corporation_id, :kana], order: {kana: 'COLLATE "C" ASC'}
  end
end
