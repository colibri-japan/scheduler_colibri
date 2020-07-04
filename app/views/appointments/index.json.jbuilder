json.array! @appointments.each do |appointment|
        json.allDay appointment.all_day?

        date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

        json.id "appointment_#{appointment.id}"
        json.title "#{appointment.patient.try(:name)} - #{appointment.nurse.try(:name)}"
        json.extract! appointment, :color, :nurse_id, :patient_id, :edit_requested, :cancelled, :service_id
        json.start appointment.starts_at.try(:strftime, date_format)
        json.end appointment.ends_at.try(:strftime, date_format)
        json.description appointment.description ? appointment.description : ''
        
        json.resourceIds appointment.resource_ids_for_calendar
        json.serviceType appointment.title || ''
        json.eventType 'appointment'
        json.eventId appointment.id
        json.completion_report_id appointment.completion_report.try(:id)

        json.patient do 
            json.name appointment.patient.name 
            json.address appointment.patient.try(:address) 
        end

        json.nurse do 
            json.name appointment.nurse.name
        end

        json.borderColor appointment.borderColor
end