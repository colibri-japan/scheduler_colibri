appointments = recurring_appointment.appointments(params[:start], params[:end])

json.array! appointments do |appointment|
	date_format = recurring_appointment.all_day_recurring_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "recurring_#{recurring_appointment.id}"
	json.title "#{recurring_appointment.patient.try(:name)} - #{recurring_appointment.nurse.try(:name)}"
	json.nurse_name recurring_appointment.nurse.try(:name)
	json.patient_name recurring_appointment.patient.try(:name)
	json.start DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.start.hour, recurring_appointment.start.min)
	json.end DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.end.hour, recurring_appointment.end.min) + recurring_appointment.duration.to_i
	json.allDay recurring_appointment.all_day_recurring_appointment? ? true : false
	json.resourceId recurring_appointment.nurse_id
	json.patientId recurring_appointment.patient_id
	if recurring_appointment.master == true && recurring_appointment.displayable == false
		json.color '#C5C5D7'
	elsif recurring_appointment.color.present?
		json.color recurring_appointment.color
	elsif recurring_appointment.color.blank?
		json.color '#7AD5DE'
	end
	if recurring_appointment.edit_requested == true
		json.borderColor '#F98050'
	elsif recurring_appointment.master == true
		json.borderColor ''
	else
		json.borderColor '#69747E'
	end
	json.master recurring_appointment.master
	json.editable recurring_appointment.displayable
	json.displayable  recurring_appointment.master == false && recurring_appointment.displayable == false ? false : true
	json.editRequested recurring_appointment.edit_requested

	json.base_url planning_recurring_appointment_path(@planning, recurring_appointment)
	json.update_url planning_recurring_appointment_path(@planning, recurring_appointment, method: :patch)
	json.edit_url edit_planning_recurring_appointment_path(@planning, recurring_appointment)
end