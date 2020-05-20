class CastPatientGenderToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :patients, :gender, :integer, default: 1, using: 'case when gender is null then null when gender then 2 else 1 end'
  end
end
