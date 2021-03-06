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

    custom_email_days.each do |date|
      custom_day_appointments =  Appointment.with_nurse_or_second_nurse_by_id(nurse_id).not_archived.edit_not_requested.where(planning_id: planning.id).in_range(date.beginning_of_day..date.end_of_day).order(starts_at: :asc)
      custom_day_private_events = @nurse.private_events.where(planning_id: planning.id, starts_at: date.beginning_of_day..date.end_of_day).order(starts_at: :asc)
      selected_appointments << custom_day_appointments.to_a
      selected_appointments << custom_day_private_events.to_a
    end
      
    selected_appointments = selected_appointments.flatten
    selected_appointments = selected_appointments.sort_by &:starts_at

    if selected_appointments.present? && @nurse.phone_mail.present?
      NurseMailer.reminder_email(@nurse, selected_appointments, custom_email_days, {custom_email_message: custom_email_message, custom_subject: custom_email_subject}).deliver_now
    end

  end
end

