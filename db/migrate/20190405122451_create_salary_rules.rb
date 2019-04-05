class CreateSalaryRules < ActiveRecord::Migration[5.1]
  def change
    create_table :salary_rules do |t|
      t.string :title
      t.references :corporation, index: true, foreign_key: true
      t.boolean :target_all_nurses, default: true
      t.text :nurse_id_list, array: true, default: []
      t.boolean :target_all_services, default: true
      t.text :service_title_list, array: true, default: []
      t.integer :date_constraint, default: 0
      t.integer :operator
      t.numeric :argument
      t.date :expires_at

      t.timestamps
    end
  end
end
