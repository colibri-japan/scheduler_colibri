class AddPhoneNumberToTeams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :phone_number, :string
  end
end
