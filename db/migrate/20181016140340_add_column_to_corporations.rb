class AddColumnToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :default_master_view, :string, default: 'agendaWeek'
  end
end
