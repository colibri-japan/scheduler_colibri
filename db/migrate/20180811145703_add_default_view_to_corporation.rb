class AddDefaultViewToCorporation < ActiveRecord::Migration[5.1]
  def change
  	add_column :corporations, :default_view, :string, default: 'agendaWeek'
  end
end
