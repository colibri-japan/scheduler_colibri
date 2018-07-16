class AddTitleToProvidedServices < ActiveRecord::Migration[5.1]
  def change
  	add_column :provided_services, :title, :string
  end
end
