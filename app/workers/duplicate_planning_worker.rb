class DuplicatePlanningWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(template_planning_id, new_planning_id)
    puts 'job started'
    template_planning = Planning.find(template_planning_id)
    new_planning = Planning.find(new_planning_id)

	  first_day = Date.new(new_planning.business_year, new_planning.business_month, 1)
		last_day = Date.new(new_planning.business_year, new_planning.business_month, -1)

		new_recurring_appointments = []
		new_appointments = []

		initial_recurring_appointments_count = template_planning.recurring_appointments.where(master: true).valid.edit_not_requested.where.not(frequency: 2).count

		template_planning.recurring_appointments.valid.edit_not_requested.where(master: true).where.not(frequency: 2).find_each do |recurring_appointment|

			new_anchor_day = first_day.wday > recurring_appointment.anchor.wday ?  first_day + 7 - (first_day.wday - recurring_appointment.anchor.wday) :  first_day + (recurring_appointment.anchor.wday - first_day.wday)

			new_recurring_appointment = recurring_appointment.dup 
			new_recurring_appointment.planning_id = new_planning.id
			new_recurring_appointment.anchor = new_anchor_day
			new_recurring_appointment.end_day = new_anchor_day + recurring_appointment.duration
			new_recurring_appointment.starts_at = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
			new_recurring_appointment.ends_at = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min)
			new_recurring_appointment.master = true
			new_recurring_appointment.displayable = true
			new_recurring_appointment.original_id = ''

			new_recurring_appointments << new_recurring_appointment
		end

		if new_recurring_appointments.count == initial_recurring_appointments_count
			RecurringAppointment.import(new_recurring_appointments)
		end

		new_recurring_appointments.each do |recurring_appointment|
			recurring_appointment_occurrences = recurring_appointment.appointments(first_day, last_day)

			recurring_appointment_occurrences.each do |occurrence|
				start_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
		    end_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i
				new_appointment = Appointment.new(title: recurring_appointment.title, nurse_id: recurring_appointment.nurse_id, recurring_appointment_id: recurring_appointment.id, patient_id: recurring_appointment.patient_id, planning_id: recurring_appointment.planning_id, master: recurring_appointment.master, displayable: true, starts_at: start_time, ends_at: end_time, color: recurring_appointment.color, edit_requested: recurring_appointment.edit_requested, description: recurring_appointment.description)
				new_appointments << new_appointment
			end
		end

    Appointment.import(new_appointments)
    
    puts 'job finished'
  end
end
