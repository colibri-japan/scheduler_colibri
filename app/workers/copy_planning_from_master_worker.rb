class CopyPlanningFromMasterWorker
	include Sidekiq::Worker
	sidekiq_options retry: false

  def perform(planning_id)
    puts 'starting copy planning job'
    planning = Planning.find(planning_id)
    corporation = planning.corporation

	  RecurringAppointment.where(planning_id: planning.id, master: false).delete_all
		Appointment.where(planning_id: planning.id, master: false).delete_all
		ProvidedService.where(planning_id: planning.id).delete_all

		new_recurring_appointments = []
		new_appointments = []
		new_provided_services = []

		recurring_appointments = RecurringAppointment.valid.edit_not_requested.from_master.not_archived.where(planning_id: planning.id)

		initial_recurring_appointments_count = recurring_appointments.count
		initial_appointments_count = Appointment.where(recurring_appointment_id: recurring_appointments.ids).count

		RecurringAppointment.valid.edit_not_requested.where(planning_id: planning.id, master: true).find_each do |recurring_appointment|
			new_recurring_appointment = recurring_appointment.dup 
			new_recurring_appointment.master = false 
			new_recurring_appointment.original_id = recurring_appointment.id
			new_recurring_appointment.skip_appointments_callbacks = true 
			new_recurring_appointments << new_recurring_appointment
		end

		if initial_recurring_appointments_count == new_recurring_appointments.count 
			RecurringAppointment.import(new_recurring_appointments)
		end

		new_recurring_appointments.each do |recurring_appointment|
			Appointment.valid.where(recurring_appointment_id: recurring_appointment.original_id).find_each do |appointment|
				new_appointment = appointment.dup 
				new_appointment.master = false 
				new_appointment.recurring_appointment_id = recurring_appointment.id 
				new_appointments << new_appointment
			end
		end

		if initial_appointments_count == new_appointments.count 
			Appointment.import(new_appointments)
		end

		new_appointments.each do |appointment|
			provided_duration = appointment.ends_at - appointment.starts_at
		  	is_provided =  Time.current + 9.hours > appointment.starts_at
      		new_provided_service = ProvidedService.new(appointment_id: appointment.id, planning_id: appointment.planning_id, service_duration: provided_duration, nurse_id: appointment.nurse_id, patient_id: appointment.patient_id, cancelled: appointment.cancelled, provided: is_provided, temporary: false, title: appointment.title, hour_based_wage: corporation.hour_based_payroll, service_date: appointment.starts_at, appointment_start: appointment.starts_at, appointment_end: appointment.ends_at)
      		new_provided_service.run_callbacks(:save) { false }
      		new_provided_services << new_provided_service
		end

		ProvidedService.import(new_provided_services)

    puts planning
    puts 'finished job'
  end
end
