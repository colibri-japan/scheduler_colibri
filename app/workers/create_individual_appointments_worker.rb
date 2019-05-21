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
        new_provided_services = []

        occurrences.each do |occurrence|
            new_appointment = Appointment.new(
                starts_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min),
                ends_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i,
                title: recurring_appointment.title,
                nurse_id: recurring_appointment.nurse_id,
                patient_id: recurring_appointment.patient_id,
                description: recurring_appointment.description,
                planning_id: recurring_appointment.planning_id,
                master: false,
                displayable: recurring_appointment.displayable,
                service_id: recurring_appointment.service_id,
                recurring_appointment_id: recurring_appointment.id,
                color: recurring_appointment.color,
                should_request_edit_for_overlapping_appointments: true
            )
            new_appointments << new_appointment
        end

        Appointment.import new_appointments 

        new_appointments.each do |appointment|
            service_salary_id = Service.where(title: appointment.title, nurse_id: appointment.nurse_id).first.id rescue nil
            provided_duration = appointment.ends_at - appointment.starts_at
            new_provided_service = ProvidedService.new(
                appointment_id: appointment.id, 
                planning_id: appointment.planning_id, 
                service_duration: provided_duration, 
                nurse_id: appointment.nurse_id, 
                patient_id: appointment.patient_id, 
                cancelled: appointment.cancelled, 
                temporary: false, 
                title: appointment.title, 
                hour_based_wage: service.hour_based_wage, 
                service_date: appointment.starts_at, 
                appointment_start: appointment.starts_at, 
                appointment_end: appointment.ends_at,
                service_salary_id: service_salary_id
            )
            new_provided_service.run_callbacks(:save) { false } 
            new_provided_services << new_provided_service
        end

        ProvidedService.import new_provided_services
    end

    private 

    def first_day_of(year, month)
        DateTime.new(year.to_i, month.to_i, 1, 0, 0, 0)
    end

    def last_day_of(year, month)
        DateTime.new(year.to_i, month.to_i, -1, 23, 59, 59)
    end

end