class DeleteAppointmentsOriginal < ActiveRecord::Migration[5.1]
  def change
    remove_column :appointments, :original_id
  end
end
