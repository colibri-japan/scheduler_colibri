class AddFullTimerToNurses < ActiveRecord::Migration[5.1]
  def change
    add_column :nurses, :full_timer, :boolean, default: false
  end
end
