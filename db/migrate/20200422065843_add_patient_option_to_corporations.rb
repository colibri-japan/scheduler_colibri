class AddPatientOptionToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :separate_patients_by_team, :boolean, default: true
  end
end
