class CancelPatientAppointmentsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(patient_id)
    patient = Patient.find(patient_id)
    puts patient.name

    planning = patient.corporation.planning

    now = Time.current.in_time_zone('Tokyo')

	  Appointment.not_archived.where(patient_id: patient_id).where('starts_at > ?', now.beginning_of_day).update_all(cancelled: true, updated_at: now)
	  ProvidedService.where('service_date > ?', now).where(patient_id: patient_id).update_all(cancelled: true, total_wage: 0, total_credits: 0, invoiced_total: 0, updated_at: now)
	  RecurringAppointment.not_archived.where(planning_id: planning.id, patient_id: patient_id).where('(recurring_appointments.termination_date IS NULL) OR ( recurring_appointments.termination_date > ?)', now).update_all(termination_date: now, updated_at: now)
  end
end