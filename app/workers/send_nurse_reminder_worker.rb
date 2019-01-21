class SendNurseReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(nurse_id, custom_email_days, options={})
    custom_email_message = options['custom_email_message']
    custom_email_subject = options['custom_email_subject']
    selected_appointments = []
    @nurse = Nurse.find(nurse_id)
    
    custom_email_days.map! {|e| e.to_date }

    planning = @nurse.corporation.planning

    puts 'nurse id'
    puts nurse_id

    puts 'custom email days'
    puts custom_email_days


    custom_email_days.each do |date|
      puts 'date'
      puts date 
      puts date.beginning_of_day
      puts date.end_of_day
      custom_day_appointments =  Appointment.valid.edit_not_requested.where(planning_id: planning.id, nurse_id: nurse_id, starts_at: date.beginning_of_day..date.end_of_day, master: false).all.order(starts_at: 'asc')
      puts 'count:'
      puts custom_day_appointments.count
      selected_appointments << custom_day_appointments.to_a
    end
      
    selected_appointments = selected_appointments.flatten

    puts 'selected appointments'
    puts selected_appointments

    if selected_appointments.present? && @nurse.phone_mail.present?
      NurseMailer.reminder_email(@nurse, selected_appointments, custom_email_days, {custom_email_message: custom_email_message, custom_subject: custom_email_subject}).deliver_now
    end
  end
end

