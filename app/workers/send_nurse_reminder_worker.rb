class SendNurseReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(nurse_id, custom_email_days, options={})
    custom_email_message = options['custom_email_message']
    custom_email_subject = options['custom_email_subject']
    selected_appointments = []
    @nurse = Nurse.find(nurse_id)

    puts 'nurse fetched by id'
    puts @nurse.name

    puts 'custom email days before map'
    puts custom_email_days
    puts custom_email_days.class.name
    
    custom_email_days.map! {|e| e.to_date }

    puts 'custom email days and class name'
    puts custom_email_days
    puts custom_email_days.class.name

    valid_planning_ids = Planning.where(corporation_id: @nurse.corporation_id, archived: false).ids

    puts 'valid plannings'
    puts valid_planning_ids


    custom_email_days.each do |date|
      custom_day_start = date.beginning_of_day
      custom_day_end = date.end_of_day
      custom_day_appointments =  Appointment.valid.edit_not_requested.where(planning_id: valid_planning_ids, nurse_id: nurse_id, starts_at: custom_day_start..custom_day_end, master: false).all.order(starts_at: 'asc')
      selected_appointments << custom_day_appointments.to_a
    end

    puts 'selected appointments'
    puts selected_appointments
      
    selected_appointments = selected_appointments.flatten

    if selected_appointments.present? && @nurse.phone_mail.present?
      puts 'selected appointments and nurse phone mail presence'
      NurseMailer.reminder_email(@nurse, selected_appointments, custom_email_days, {custom_email_message: custom_email_message, custom_subject: custom_email_subject}).deliver_now
    end
  end
end

