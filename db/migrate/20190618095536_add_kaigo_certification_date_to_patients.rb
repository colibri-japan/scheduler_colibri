class AddKaigoCertificationDateToPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :kaigo_certification_date, :date
  end
end
