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

		recurring_appointments = template_planning.recurring_appointments.to_be_copied_to_new_planning
		puts recurring_appointments.count

		initial_recurring_appointments_count = recurring_appointments.count

		recurring_appointments.find_each do |recurring_appointment|

			# new_anchor_day = first_day.wday > recurring_appointment.anchor.wday ?  first_day + 7 - (first_day.wday - recurring_appointment.anchor.wday) :  first_day + (recurring_appointment.anchor.wday - first_day.wday)
			new_anchor_day = recurring_appointment.appointments(first_day, last_day).first
			new_recurring_appointment = recurring_appointment.dup 
			new_recurring_appointment.planning_id = new_planning.id
			new_recurring_appointment.anchor = new_anchor_day
			new_recurring_appointment.end_day = new_anchor_day + recurring_appointment.duration
			new_recurring_appointment.starts_at = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
			new_recurring_appointment.ends_at = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min)
			new_recurring_appointment.master = true
			new_recurring_appointment.displayable = true
			new_recurring_appointment.original_id = ''

			if new_recurring_appointment.frequency == 6
				exception_time = last_day - (last_day.wday - new_recurring_appointment.anchor.wday) % 7
				new_recurring_appointment.schedule.add_exception_time exception_time
			end

			new_recurring_appointments << new_recurring_appointment
		end

		puts new_recurring_appointments.count

		if new_recurring_appointments.count == initial_recurring_appointments_count
			puts 'recurring appointments count match'
			RecurringAppointment.import(new_recurring_appointments)
		end

		new_recurring_appointments.each do |recurring_appointment|
			puts 'inside recurring appointments loop'
			recurring_appointment_occurrences = recurring_appointment.appointments(first_day, last_day)

			recurring_appointment_occurrences.each do |occurrence|
				start_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
		    end_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i
				new_appointment = Appointment.new(title: recurring_appointment.title, nurse_id: recurring_appointment.nurse_id, recurring_appointment_id: recurring_appointment.id, patient_id: recurring_appointment.patient_id, planning_id: recurring_appointment.planning_id, master: recurring_appointment.master, displayable: true, starts_at: start_time, ends_at: end_time, color: recurring_appointment.color, edit_requested: recurring_appointment.edit_requested, description: recurring_appointment.description)
				new_appointments << new_appointment
			end
		end

		puts 'before saving appointments'
		Appointment.import(new_appointments)
		puts 'after saving appointments'
    
    puts 'job finished'
  end
end
