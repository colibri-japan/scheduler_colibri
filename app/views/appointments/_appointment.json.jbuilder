json.allDay appointment.all_day?

date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

json.id "appointment_#{appointment.id}"
json.title "#{appointment.patient.try(:name)} - #{appointment.nurse.try(:name)}"
json.extract! appointment, :color, :nurse_id, :patient_id, :edit_requested, :cancelled, :service_id
json.start appointment.starts_at.try(:strftime, date_format)
json.end appointment.ends_at.try(:strftime, date_format)
json.description appointment.description ? appointment.description : ''
json.resourceIds ["nurse_#{appointment.nurse_id}", "patient_#{appointment.patient_id}"]
json.nurse do 
    json.name appointment.nurse.name 
end
json.patient do 
    json.name appointment.patient.name 
    json.address appointment.patient.address 
end
json.serviceType appointment.title || ''

json.frequency appointment.recurring_appointment.frequency if appointment.recurring_appointment_id.present?

json.borderColor appointment.borderColor    
json.eventType 'appointment'

json.base_url planning_appointment_path(appointment.planning, appointment)
json.edit_url edit_planning_appointment_path(appointment.planning, appointment)
json.recurring_appointment_path "/plannings/#{appointment.planning_id}/recurring_appointments/#{appointment.recurring_appointment_id}/edit" if appointment.recurring_appointment_id.present?
