class EmailNurseWagesWorker
  include Sidekiq::Worker 
  sidekiq_options retry: false 

  def perform(corporation_id, year, month)
    corporation = Corporation.find(corporation_id)

    range_start = DateTime.new(year.to_i, month.to_i, 1, 0, 0, 0)
    end_of_month = range_start.end_of_month
    range_end = Time.current.in_time_zone('Tokyo') > end_of_month ? end_of_month : Time.current.in_time_zone('Tokyo') 

    puts 'ranges'
    puts range_start
    puts range_end 

    puts 'nurses with appointments'
    puts corporation.nurses.with_appointments_between(range_start, range_end).pluck(:name)

    data = corporation.nurses.with_appointments_between(range_start, range_end).payable_summary_for(range_start..range_end)

    puts 'data'
    puts data

    #perform corporation mailer action
    CorporationMailer.all_nurses_payable_email(corporation, data, range_start).deliver_now
  end

end