class DropDefaultPatientGender < ActiveRecord::Migration[5.1]
  def change
    change_column_default :patients, :gender, nil
  end
end
