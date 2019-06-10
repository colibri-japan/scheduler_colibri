class AddAvailabilitiesFieldsToPrintingOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :printing_options, :print_sunday_availabilities, :boolean, default: true
    add_column :printing_options, :print_saturday_availabilities, :boolean, default: true
  end
end
