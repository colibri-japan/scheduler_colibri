date_format = appointment.all_day_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

json.id "appointment_#{appointment.id}"
json.title "#{appointment.patient.try(:name)} - #{appointment.nurse.try(:name)}"
json.extract! appointment, :description, :start, :end, :color, :master, :displayable
json.resourceId appointment.nurse_id
json.patientId appointment.patient_id
json.nurse_name appointment.nurse.try(:name)
json.patient_name appointment.patient.try(:name)

json.editRequested appointment.edit_requested

if appointment.edit_requested == true
	json.borderColor '#F98050'
elsif appointment.original_id.present?
	json.borderColor '#69747E'
end

json.allDay appointment.all_day_appointment?

json.base_url planning_appointment_url(@planning, appointment)
json.edit_url edit_planning_appointment_url(@planning, appointment)
json.update_url planning_appointment_url(@planning, appointment, method: :patch)

