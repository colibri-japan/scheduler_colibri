class UpdateIndividualAppointmentsWorker
	include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(recurring_appointment_id)
        recurring_appointment = RecurringAppointment.find(recurring_appointment_id)

        appointments = Appointment.not_archived.where(recurring_appointment_id: recurring_appointment_id).order(starts_at: :asc)
        
        if appointments.present?
            year_and_months_updated = appointments.pluck(:starts_at).map {|d| [d.year, d.month]}.uniq 

            #delete appointments unless completion report is present
            appointments.each do |appointment|
                appointment.delete unless appointment.completion_report.present?
            end

            # create appointments in this range  
            occurrences = recurring_appointment.appointments(recurring_appointment.anchor - 1.day, appointments.last.starts_at.end_of_month)

            new_appointments = []

            occurrences.each do |occurrence|
                appointment = Appointment.new

                appointment.starts_at = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
                appointment.ends_at = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + (recurring_appointment.duration.to_i)
                appointment.color = recurring_appointment.color
                appointment.description = recurring_appointment.description
                appointment.title = recurring_appointment.title 
                appointment.nurse_id = recurring_appointment.nurse_id 
                appointment.patient_id = recurring_appointment.patient_id 
                appointment.service_id = recurring_appointment.service_id
                appointment.planning_id = recurring_appointment.planning_id
                appointment.recurring_appointment_id = recurring_appointment.id

                #instead of batch validation, validate each appointment
                appointment.edit_requested = true unless appointment.valid?
                appointment.run_callbacks(:save) { false }

                new_appointments << appointment
            end

            Appointment.import(new_appointments)

            year_and_months_updated.each do |year, month|
                RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(recurring_appointment.nurse_id, year, month)
            end
        end

    end

    private 


end