class CreateIndividualAppointmentsWorker
	include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(recurring_appointment_id, year1, month1, year2, month2, year3, month3, select_year_and_month_2, select_year_and_month_3)
        recurring_appointment = RecurringAppointment.find(recurring_appointment_id.to_i)
        service = recurring_appointment.service
        
        month_1_occurrences = recurring_appointment.appointments(first_day_of(year1, month1), last_day_of(year1, month1))
        month_2_occurrences = select_year_and_month_2 == 'true' ? recurring_appointment.appointments(first_day_of(year2, month2), last_day_of(year2, month2)) : []
        month_3_occurrences = select_year_and_month_3 == 'true' ? recurring_appointment.appointments(first_day_of(year3, month3), last_day_of(year3, month3)) : []

        occurrences = (month_1_occurrences + month_2_occurrences + month_3_occurrences).flatten
        
        new_appointments = []

        occurrences.each do |occurrence|
            new_appointment = Appointment.new(
                starts_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min),
                ends_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i,
                title: recurring_appointment.title,
                nurse_id: recurring_appointment.nurse_id,
                patient_id: recurring_appointment.patient_id,
                description: recurring_appointment.description,
                planning_id: recurring_appointment.planning_id,
                service_id: recurring_appointment.service_id,
                recurring_appointment_id: recurring_appointment.id,
                original_recurring_appointment_id: recurring_appointment.id,
                color: recurring_appointment.color,
                should_request_edit_for_overlapping_appointments: true
            )
            new_appointment.run_callbacks(:save) { false }
            new_appointments << new_appointment
        end

        Appointment.import new_appointments 
    end

    private 

    def first_day_of(year, month)
        DateTime.new(year.to_i, month.to_i, 1, 0, 0, 0)
    end

    def last_day_of(year, month)
        DateTime.new(year.to_i, month.to_i, -1, 23, 59, 59)
    end

end