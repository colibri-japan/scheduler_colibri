appointments = recurring_appointment.appointments(params[:start], params[:end])
json.array! appointments do |appointment|
	json.id "recurring_#{recurring_appointment.id}"
	json.title recurring_appointment.title
	json.start appointment.strftime('%Y-%m-%d')
	json.end (appointment + 1.day).strftime('%Y-%m-%d')
	json.allDay true

	json.base_url recurring_appointment_path(recurring_appointment)
	json.update_url recurring_appointment_path(recurring_appointment, method: :patch)
	json.edit_url edit_recurring_appointment_path(recurring_appointment)
end