json.allDay appointment.all_day?

date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

json.id "appointment_#{appointment.id}"
json.title "#{appointment.patient.try(:name)} - #{appointment.nurse.try(:name)}"
json.extract! appointment, :color, :nurse_id, :patient_id, :edit_requested, :cancelled, :service_id
json.start appointment.starts_at.try(:strftime, date_format)
json.end appointment.ends_at.try(:strftime, date_format)
json.description appointment.description ? appointment.description : ''
json.resourceIds appointment.resource_ids_for_calendar
json.nurse do 
    json.name appointment.nurse.name 
end
json.patient do 
    json.name appointment.patient.name 
    json.address appointment.patient.address 
end
json.serviceType appointment.title || ''
json.completion_report_id appointment.completion_report.try(:id)

json.borderColor appointment.borderColor    
json.eventType 'appointment'
json.eventId appointment.id
