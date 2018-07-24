date_format = appointment.all_day_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id "appointment_#{appointment.id}"
json.title "#{appointment.patient.try(:name)} - #{appointment.title}"
json.extract! appointment, :description, :start, :end
json.resourceId appointment.nurse_id
json.patientId appointment.patient_id

json.allDay appointment.all_day_appointment? ? true : false

json.base_url planning_appointment_url(@planning, appointment)
json.edit_url edit_planning_appointment_url(@planning, appointment)
json.update_url planning_appointment_url(@planning, appointment, method: :patch)
