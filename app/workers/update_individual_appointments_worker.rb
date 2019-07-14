class UpdateIndividualAppointmentsWorker
	include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(recurring_appointment_id)
        recurring_appointment = RecurringAppointment.find(recurring_appointment_id)

        appointments = Appointment.not_archived.where(recurring_appointment_id: recurring_appointment_id).order(starts_at: :asc)

        if appointments.present?

            delta = (recurring_appointment.anchor - appointments.first.starts_at.to_date).to_i.remainder(7)

            appointments.each do |appointment|

                appointment.starts_at = DateTime.new(appointment.starts_at.year, appointment.starts_at.month, appointment.starts_at.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min) + delta.days
                appointment.ends_at = DateTime.new(appointment.ends_at.year, appointment.ends_at.month, appointment.ends_at.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + delta.days
                appointment.color = recurring_appointment.color 
                appointment.description = recurring_appointment.description 
                appointment.title = recurring_appointment.title 
                appointment.nurse_id = recurring_appointment.nurse_id 
                appointment.patient_id = recurring_appointment.patient_id 
                appointment.service_id = recurring_appointment.service_id  
                appointment.should_request_edit_for_overlapping_appointments = true
                appointment.recurring_appointment_id = recurring_appointment.id

                appointment.save
            end 

            years_and_months_updated = appointments.pluck(:starts_at).map {|d| [d.year, d.month]}.uniq

            years_and_months_updated.each do |year, month|
                RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(recurring_appointment.nurse_id, year, month)
            end
        end

    end

    private 


end