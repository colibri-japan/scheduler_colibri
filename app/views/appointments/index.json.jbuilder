json.array!(@appointments) do |appointment|
json.id "appointment_#{appointment.id}"
json.extract! appointment, :title, :description, :start, :end
json.resourceId appointment.nurse_id

json.base_url planning_appointment_url(@planning, appointment)
json.edit_url edit_planning_appointment_url(@planning, appointment)
json.update_url planning_appointment_url(@planning, appointment, method: :patch)
end