class RecalculateWagesWorker
  include Sidekiq::Worker 
  sidekiq_options retry: false 

  def perform(nurse_id, year, month)
    nurse = Nurse.find(nurse_id)
  end

end