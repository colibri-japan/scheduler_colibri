class CreateScans < ActiveRecord::Migration[5.1]
  def change
    create_table :scans do |t|
      t.references :planning, foreign_key: true
      t.timestamp :done_at
      t.timestamp :cancelled_at
      t.string :teikyohyo

      t.timestamps
    end
  end
end
