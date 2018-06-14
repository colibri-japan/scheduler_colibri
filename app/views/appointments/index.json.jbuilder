json.array!(@appointments) do |appointment|
json.id "appointment_#{appointment.id}"
json.extract! appointment, :description, :start, :end
json.title "#{appointment.patient.name} - #{appointment.title}"
json.resourceId appointment.nurse_id

json.base_url planning_appointment_url(@planning, appointment)
json.edit_url edit_planning_appointment_url(@planning, appointment)
json.update_url planning_appointment_url(@planning, appointment, method: :patch)
end