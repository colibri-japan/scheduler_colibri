class AddPlanningToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :planning, index: true
  end
end
