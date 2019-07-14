json.allDay appointment.all_day_appointment?

date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

json.id "appointment_#{appointment.id}"
json.title "#{appointment.patient.try(:name)} - #{appointment.nurse.try(:name)}"
json.extract! appointment, :color, :nurse_id, :patient_id, :edit_requested, :cancelled
json.start appointment.starts_at.try(:strftime, date_format)
json.end appointment.ends_at.try(:strftime, date_format)
json.description appointment.description ? appointment.description : ''
json.resourceId params[:patient_resource].present? ? appointment.patient_id : appointment.nurse_id
json.nurse do 
    json.name appointment.nurse.name 
end
json.patient do 
    json.name appointment.patient.name 
    json.address appointment.patient.address 
end
json.service_type appointment.title ? appointment.title : ''
json.private_event false

json.frequency appointment.recurring_appointment.frequency if appointment.recurring_appointment_id.present?

if appointment.cancelled == true
    json.borderColor '#FF8484'
elsif appointment.edit_requested == true
    json.borderColor '#99E6BF'
end
json.eventType 'appointment'

json.base_url planning_appointment_path(appointment.planning, appointment)
json.edit_url edit_planning_appointment_path(appointment.planning, appointment)
json.recurring_appointment_path "/plannings/#{appointment.planning_id}/recurring_appointments/#{appointment.recurring_appointment_id}/edit" if appointment.recurring_appointment_id.present?

puts 'resource id'
puts json.resourceId