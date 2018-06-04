class CreateNurses < ActiveRecord::Migration[5.1]
  def change
    create_table :nurses do |t|
      t.string :name
      t.string :phone_number
      t.string :phone_mail
      t.string :address

      t.timestamps
    end
  end
end
