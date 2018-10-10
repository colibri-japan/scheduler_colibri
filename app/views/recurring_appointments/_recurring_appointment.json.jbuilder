appointments = recurring_appointment.appointments(params[:start], params[:end])

json.array! appointments do |appointment|
	json.allDay recurring_appointment.all_day_recurring_appointment? ? true : false
	date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "recurring_#{recurring_appointment.id}"
	json.extract! recurring_appointment, :description, :color, :master, :displayable, :frequency, :edit_requested, :patient_id, :nurse_id
	json.title "#{recurring_appointment.patient.try(:name)} - #{recurring_appointment.nurse.try(:name)}"
	json.nurse_name recurring_appointment.nurse.try(:name)
	json.patient_name recurring_appointment.patient.try(:name)
	json.start DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.start.hour, recurring_appointment.start.min)
	json.end DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.end.hour, recurring_appointment.end.min) + recurring_appointment.duration.to_i
	json.resourceId recurring_appointment.nurse_id
	if recurring_appointment.edit_requested == true
		json.borderColor '#F98050'
	elsif recurring_appointment.original_id.present?
		json.borderColor '#69747E'
	end

	json.base_url planning_recurring_appointment_path(@planning, recurring_appointment)
	json.update_url planning_recurring_appointment_path(@planning, recurring_appointment, method: :patch)
	json.edit_url edit_planning_recurring_appointment_path(@planning, recurring_appointment)
end