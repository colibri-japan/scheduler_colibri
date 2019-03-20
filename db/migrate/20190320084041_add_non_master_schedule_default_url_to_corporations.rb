class AddNonMasterScheduleDefaultUrlToCorporations < ActiveRecord::Migration[5.1]
  def change
    add_column :corporations, :non_master_schedule_default_url, :string
  end
end
