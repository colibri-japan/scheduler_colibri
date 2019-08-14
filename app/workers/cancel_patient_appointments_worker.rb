class CancelPatientAppointmentsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(patient_id)
    patient = Patient.find(patient_id)

    now = Time.current.in_time_zone('Tokyo')

	  patient.appointments.not_archived.where('starts_at > ?', now.beginning_of_day).update_all(cancelled: true, updated_at: now)
	  patient.recurring_appointments.not_archived.where('(recurring_appointments.termination_date IS NULL) OR ( recurring_appointments.termination_date > ?)', now).update_all(termination_date: now, updated_at: now)
  end
end