class AddPhoneNumberToCareManager < ActiveRecord::Migration[5.1]
  def change
    add_column :care_managers, :phone_number, :string
  end
end
