class EmailMonthlyAppointmentsReportWorker
    include Sidekiq::Worker 
    sidekiq_options retry: false 
  
    def perform(corporation_id, year, month)
      corporation = Corporation.find(corporation_id)
      planning = corporation.planning

      start_date = Date.new(year.to_i, month.to_i, 1).beginning_of_day
      end_date = Date.new(year.to_i, month.to_i, -1).end_of_day

      appointments = planning.appointments.not_archived.edit_not_requested.in_range(start_date..end_date).includes(:nurse, :service, patient: :care_managers).order('nurses.kana COLLATE "C" asc')
  
      #perform corporation mailer action
      CorporationMailer.monthly_appointments_email(corporation, year, month, appointments).deliver_now
    end
  
  end