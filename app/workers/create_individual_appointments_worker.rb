class CreateIndividualAppointmentsWorker
	include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(recurring_appointment_id, year1, month1, year2, month2, select_year_and_month_2)
        puts recurring_appointment_id
        puts year1
        puts month1
        puts  year2
        puts  month2
        puts select_year_and_month_2
        puts select_year_and_month_2.class.name
        first_day = DateTime.new(year1.to_i, month1.to_i, 1, 0, 0, 0)
        last_day = select_year_and_month_2 == 'true' ? DateTime.new(year2.to_i, month2.to_i, -1, 23, 59, 59) : DateTime.new(year1.to_i, month1.to_i, -1, 0, 0, 0)
        recurring_appointment = RecurringAppointment.find(recurring_appointment_id.to_i)
        service = recurring_appointment.service

        puts first_day
        puts last_day

        occurrences = recurring_appointment.appointments(first_day, last_day)

        puts 'occurrences'
        puts occurrences

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
                color: recurring_appointment.color
            )
            new_appointments << new_appointment
        end

        Appointment.import new_appointments 

        new_appointments.each do |appointment|
            provided_duration = appointment.ends_at - appointment.starts_at
	        is_provided =  Time.current + 9.hours > appointment.starts_at
            new_provided_service = ProvidedService.new(
                appointment_id: appointment.id, 
                planning_id: appointment.planning_id, 
                service_duration: provided_duration, 
                nurse_id: appointment.nurse_id, 
                patient_id: appointment.patient_id, 
                cancelled: appointment.cancelled, 
                provided: is_provided, 
                temporary: false, 
                title: appointment.title, 
                hour_based_wage: service.hour_based_wage, 
                service_date: appointment.starts_at, 
                appointment_start: appointment.starts_at, 
                appointment_end: appointment.ends_at
            )
            new_provided_service.run_callbacks(:save) { false } 
            new_provided_services << new_provided_service
        end

        ProvidedService.import new_provided_services
    end

end