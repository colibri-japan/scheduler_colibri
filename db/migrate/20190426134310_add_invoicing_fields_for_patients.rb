class AddInvoicingFieldsForPatients < ActiveRecord::Migration[5.1]
  def change
    add_column :patients, :insurance_id, :string
    add_column :patients, :birthday, :date
    add_column :patients, :kaigo_certification_validity_start, :date
    add_column :patients, :kaigo_certification_validity_end, :date
    add_column :patients, :ratio_paid_by_patient, :integer
    add_column :patients, :public_assistance_id_1, :string
    add_column :patients, :public_assistance_id_2, :string
  end
end
