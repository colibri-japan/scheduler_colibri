class SynchronizeAppointmentsWithRecurringAppointmentWorker
  include Sidekiq::Worker
  sidekiq_options retry: false


  def perform(recurring_appointment_id, appointment_ids)
    puts 'performing synchronization'

    appointments = Appointment.where(id: appointment_ids) 
    recurring_appointment = RecurringAppointment.find(recurring_appointment_id)

    appointments.each do |appointment|
      appointment.starts_at = DateTime.new(appointment.starts_at.year, appointment.starts_at.month, appointment.starts_at.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
      appointment.ends_at = DateTime.new(appointment.ends_at.year, appointment.ends_at.month, appointment.ends_at.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min)
      appointment.color = recurring_appointment.color 
      appointment.description = recurring_appointment.description 
      appointment.title = recurring_appointment.title 
      appointment.nurse_id = recurring_appointment.nurse_id 
      appointment.patient_id = recurring_appointment.patient_id 
      appointment.service_id = recurring_appointment.service_id  
      appointment.should_request_edit_for_overlapping_appointments = true
      appointment.displayable = true 
      appointment.master = false 
      appointment.recurring_appointment_id = recurring_appointment.id

      appointment.save
    end
  end


end