class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.text :body
      t.references :corporations, foreign_key: true
      
      t.timestamps
    end
  end
end
