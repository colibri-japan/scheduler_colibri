class CreateRecurringAppointments < ActiveRecord::Migration[5.1]
  def change
    create_table :recurring_appointments do |t|
    	t.string :title
    	t.date :anchor
    	t.integer :frequency

    	t.timestamps
    end
  end
end
