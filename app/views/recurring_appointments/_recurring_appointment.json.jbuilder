appointments = recurring_appointment.appointments(params[:start], params[:end])
json.array! appointments do |appointment|
	date_format = recurring_appointment.all_day_recurring_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "recurring_#{recurring_appointment.id}"
	json.title recurring_appointment.title
	json.start DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.start.hour, recurring_appointment.start.min)
	json.end DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.end.hour, recurring_appointment.end.min)
	json.allDay recurring_appointment.all_day_recurring_appointment? ? true : false
	json.resourceId recurring_appointment.nurse_id

	json.base_url planning_recurring_appointment_path(@planning, recurring_appointment)
	json.update_url planning_recurring_appointment_path(@planning, recurring_appointment, method: :patch)
	json.edit_url edit_planning_recurring_appointment_path(@planning, recurring_appointment)
end