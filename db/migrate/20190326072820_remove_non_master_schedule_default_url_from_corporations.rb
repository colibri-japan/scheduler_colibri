class RemoveNonMasterScheduleDefaultUrlFromCorporations < ActiveRecord::Migration[5.1]
  def change
    remove_column :corporations, :non_master_schedule_default_url
  end
end
