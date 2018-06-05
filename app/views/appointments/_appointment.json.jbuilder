date_format = appointment.all_day_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id "appointment_#{appointment.id}"
json.extract! appointment, :title, :description, :start, :end

json.allDay appointment.all_day_appointment? ? true : false

json.base_url planning_appointment_url(@planning, appointment)
json.edit_url edit_planning_appointment_url(@planning, appointment)
json.update_url planning_appointment_url(@planning, appointment, method: :patch)
