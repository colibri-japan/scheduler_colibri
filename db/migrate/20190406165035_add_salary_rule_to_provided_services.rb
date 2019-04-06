class AddSalaryRuleToProvidedServices < ActiveRecord::Migration[5.1]
  def change
    add_reference :provided_services, :salary_rule, index: true
  end
end
