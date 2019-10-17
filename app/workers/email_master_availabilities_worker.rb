class EmailMasterAvailabilitiesWorker
  include Sidekiq::Worker 
  sidekiq_options retry: false 

  def perform(date, user_id)
    user = User.find(user_id)
    corporation = user.corporation
    query_day = date.to_date rescue nil

    master_availabilities = query_day.present? ? corporation.nurses.displayable.not_archived.master_availabilities_per_slot_and_wday(query_day) : []

    UserMailer.master_availabilities(query_day, master_availabilities, user).deliver_now
  end

end