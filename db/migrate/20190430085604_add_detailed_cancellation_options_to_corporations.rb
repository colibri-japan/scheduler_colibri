class AddDetailedCancellationOptionsToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :detailed_cancellation_options, :boolean, default: true
  end
end
