class CreateRecurringUnavailabilities < ActiveRecord::Migration[5.1]
  def change
    create_table :recurring_unavailabilities do |t|
      t.string :title
      t.date :anchor
      t.integer :frequency
      t.datetime :start_time
      t.datetime :end_time
      t.references :planning, index: true
      t.references :nurse, index: true

      t.timestamps
    end
  end
end
