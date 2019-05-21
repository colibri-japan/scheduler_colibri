class CopyPatientPlanningFromMasterWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(patient_id, month, year)
    patient = Patient.find(patient_id)
    corporation = patient.corporation
    planning = corporation.planning

    first_day = DateTime.new(year.to_i, month.to_i, 1, 0, 0, 0)
    last_day = DateTime.new(year.to_i, month.to_i, -1, 23, 59, 59)

    new_recurring_appointments = []
    new_appointments = []
    new_provided_services = []

    recurring_appointments = planning.recurring_appointments.from_master.where(patient_id: patient.id).to_be_displayed.edit_not_requested.not_terminated_at(first_day)

    recurring_appointments.find_each do |recurring_appointment|
      occurrences = recurring_appointment.appointments(first_day, last_day)
      occurrences.each do |occurrence|
        new_appointment = Appointment.new(
          starts_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min),
          ends_at: DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i,
          title: recurring_appointment.title,
          color: recurring_appointment.color, 
          nurse_id: recurring_appointment.nurse_id, 
          patient_id: recurring_appointment.patient_id,
          description: recurring_appointment.description,
          planning_id: recurring_appointment.planning_id,
          master: false,
          displayable: true,
          recurring_appointment_id: recurring_appointment.id,
          service_id: recurring_appointment.service_id,
          duration: recurring_appointment.duration,
          should_request_edit_for_overlapping_appointments: true
        )
        new_appointments << new_appointment 
      end
    end

    Appointment.import(new_appointments)

    new_appointments.each do |appointment|
      if appointment.id.present?
        service_salary_id = Service.where(title: appointment.title.first, nurse_id: appointment.nurse_id).first.present? ? Service.where(title: appointment.title.first, nurse_id: appointment.nurse_id).first : appointment.service_id
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
          hour_based_wage: corporation.hour_based_payroll, 
          service_date: appointment.starts_at, 
          appointment_start: appointment.starts_at, 
          appointment_end: appointment.ends_at,
          service_salary_id: service_salary_id
        )
        new_provided_service.run_callbacks(:save) { false }
        new_provided_services << new_provided_service
      end
    end

    ProvidedService.import(new_provided_services)
  end
end
