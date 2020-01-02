class AddDeviceTokensToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :android_fcm_token, :string
    add_column :users, :ios_fcm_token, :string
  end
end
