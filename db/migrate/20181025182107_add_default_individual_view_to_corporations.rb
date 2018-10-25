class AddDefaultIndividualViewToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :default_individual_view, :string, default: 'agendaWeek'
  end
end
