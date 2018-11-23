class CancelPatientAppointmentsWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(patient_id)
    patient = Patient.find(patient_id)
    puts patient.name

    valid_plannings = patient.corporation.plannings.where('(business_month >= ? AND business_year = ?) OR (business_year > ?)', Time.current.month, Time.current.year, Time.current.year)
    puts valid_plannings.ids

	Appointment.to_be_displayed.where(patient_id: patient_id, master: false).where('starts_at > ?', Time.current).update_all(cancelled: true)
	ProvidedService.where('service_date > ?', Time.current).where(patient_id: patient_id).update_all(cancelled: true)
	RecurringAppointment.to_be_displayed.from_master.where(planning_id: valid_plannings.ids, patient_id: patient_id).update_all(duplicatable: false)
  end
end