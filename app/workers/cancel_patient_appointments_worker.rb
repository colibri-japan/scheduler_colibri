class CancelPatientAppointmentsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(patient_id)
    patient = Patient.find(patient_id)
    puts patient.name

    planning = patient.corporation.planning

    now = Time.current 

	  Appointment.to_be_displayed.where(patient_id: patient_id, master: false).where('starts_at > ?', now).update_all(cancelled: true, updated_at: now)
	  ProvidedService.where('service_date > ?', now).where(patient_id: patient_id).update_all(cancelled: true, updated_at: now)
	  RecurringAppointment.to_be_displayed.from_master.where(planning_id: planning.id, patient_id: patient_id).where('(recurring_appointments.termination_date IS NULL) OR ( recurring_appointments.termination_date > ?)', now).update_all(termination_date: now, updated_at: now)
  end
end