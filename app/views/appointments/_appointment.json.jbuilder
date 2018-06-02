date_format = appointment.all_day_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id "appointment_#{appointment.id}"
json.extract! appointment, :title, :description, :start, :end

json.allDay appointment.all_day_appointment? ? true : false

json.base_url appointment_url(appointment)
json.edit_url edit_appointment_url(appointment)
json.update_url appointment_url(appointment, method: :patch)
