class AddPrintNurseDescriptionInMasterToPrintingOptions < ActiveRecord::Migration[5.1]
  def change
    add_column :printing_options, :print_nurse_description_in_master, :boolean, default: false
  end
end
