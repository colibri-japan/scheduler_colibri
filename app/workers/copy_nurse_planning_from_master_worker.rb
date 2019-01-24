class CopyNursePlanningFromMasterWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(nurse_id, month, year)
    nurse = Nurse.find(nurse_id)
    corporation = nurse.corporation
    planning = corporation.planning

    first_day = DateTime.new(year.to_i, month.to_i, 1, 0, 0, 0)
    last_day = DateTime.new(year.to_i, month.to_i, -1, 23, 59, 59)

    new_recurring_appointments = []
    new_appointments = []
    new_provided_services = []

    recurring_appointments = planning.recurring_appointments.from_master.where(nurse_id: nurse.id).to_be_displayed.edit_not_requested.where('(recurring_appointments.termination_date IS NULL) OR ( recurring_appointments.termination_date > ?)', first_day)

    recurring_appointments.find_each do |recurring_appointment|
      new_anchor = recurring_appointment.appointments(first_day, last_day).first
      if new_anchor.present? 
        new_recurring_appointment = recurring_appointment.dup 
        new_recurring_appointment.master = false 
        new_recurring_appointment.original_id = recurring_appointment.id
        new_recurring_appointment.skip_appointments_callbacks = true 
        new_recurring_appointment.anchor = new_anchor
        
        new_recurring_appointments << new_recurring_appointment
      end
    end


    RecurringAppointment.import(new_recurring_appointments)

    new_recurring_appointments.each do |r|
      occurrences = r.appointments(first_day, last_day)

      occurrences.each do |occurrence|
        new_appointment = Appointment.new(
          starts_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, r.starts_at.hour, r.starts_at.min),
          ends_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, r.ends_at.hour, r.ends_at.min),
          title: r.title,
          color: r.color,
          nurse_id: r.nurse_id,
          patient_id: r.patient_id,
          description: r.description,
          planning_id: r.planning_id,
          master: false,
          displayable: true,
          recurring_appointment_id: r.id,
          service_id: r.service_id,
          duration: r.duration,
          request_edit_for_overlapping_appointments: true
        )
        new_appointment.run_callbacks(:create) { false }
        new_appointments << new_appointment
      end
    end

    Appointment.import(new_appointments)

    new_appointments.each do |appointment|  
      provided_duration = appointment.ends_at - appointment.starts_at
		  is_provided =  Time.current + 9.hours > appointment.starts_at
      new_provided_service = ProvidedService.new(appointment_id: appointment.id, planning_id: appointment.planning_id, service_duration: provided_duration, nurse_id: appointment.nurse_id, patient_id: appointment.patient_id, cancelled: appointment.cancelled, provided: is_provided, temporary: false, title: appointment.title, hour_based_wage: corporation.hour_based_payroll, service_date: appointment.starts_at, appointment_start: appointment.starts_at, appointment_end: appointment.ends_at)
      new_provided_service.run_callbacks(:save) { false }
      new_provided_services << new_provided_service
    end

    ProvidedService.import(new_provided_services)
  end
end
