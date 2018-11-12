class SendNurseReminderWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(nurse_id, selected_appointments_ids, custom_email_days, custom_email_message, custom_email_subject)
    puts nurse_id 
    puts selected_appointments_ids 
    puts custom_email_days 
    puts custom_email_message 
    puts custom_email_subject

    # @nurse = Nurse.find(nurse_id)
    # @selected_appointments = selected_appointments_ids.map{|id| Appointment.find(id)}
    # NurseMailer.reminder_email(@nurse, @selected_appointments, custom_email_days, {custom_email_message: custom_email_message, custom_subject: custom_email_subject}).deliver
  end
end
