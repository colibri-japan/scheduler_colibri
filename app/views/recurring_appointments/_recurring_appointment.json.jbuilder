appointments = recurring_appointment.appointments(params[:start], params[:end])

json.array! appointments do |appointment|
	date_format = recurring_appointment.all_day_recurring_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "recurring_#{recurring_appointment.id}"
	json.title "#{recurring_appointment.patient.try(:name)} - #{recurring_appointment.nurse.try(:name)}"
	json.start DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.start.hour, recurring_appointment.start.min)
	json.end DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.end.hour, recurring_appointment.end.min)
	json.allDay recurring_appointment.all_day_recurring_appointment? ? true : false
	json.resourceId recurring_appointment.nurse_id
	json.patientId recurring_appointment.patient_id
	if recurring_appointment.master == true && recurring_appointment.displayable == false
		json.color '#E8E8EE'
	elsif recurring_appointment.color.present?
		json.color recurring_appointment.color
	elsif recurring_appointment.color.blank? && recurring_appointment.master == true
		json.color '#74d680'
	elsif recurring_appointment.color.blank? && recurring_appointment.master == false
		json.color '#7AD5DE'
	end
	json.borderColor recurring_appointment.master == true ? '' : '#4f5b66'
	json.editable recurring_appointment.displayable == true ? true : false
	json.textColor '#aaa' if recurring_appointment.displayable == false
	json.displayable  recurring_appointment.master == false && recurring_appointment.displayable == false ? false : true

	json.base_url planning_recurring_appointment_path(@planning, recurring_appointment)
	json.update_url planning_recurring_appointment_path(@planning, recurring_appointment, method: :patch)
	json.edit_url edit_planning_recurring_appointment_path(@planning, recurring_appointment)
end