class CreateDeletedOccurrences < ActiveRecord::Migration[5.1]
  def change
    create_table :deleted_occurrences do |t|
      t.references :recurring_appointment, index: true
      t.date :deleted_day

      t.timestamps
    end
  end
end
