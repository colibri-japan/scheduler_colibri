class AddIncludeDescriptionInNurseMailerToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :include_description_in_nurse_mailer, :boolean, default: false
  end
end
