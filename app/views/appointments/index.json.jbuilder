json.array!(@appointments) do |appointment|
json.id "appointment_#{appointment.id}"
json.extract! appointment, :title, :description, :start, :end

json.base_url appointment_url(appointment)
json.edit_url edit_appointment_url(appointment)
json.update_url appointment_url(appointment, method: :patch)
end