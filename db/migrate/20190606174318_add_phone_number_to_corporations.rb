class AddPhoneNumberToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :phone_number, :string
  end
end
