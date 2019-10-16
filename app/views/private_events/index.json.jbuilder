json.array! @private_events.each do |private_event|
    json.allDay private_event.all_day? 
    date_format = private_event.all_day? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
    
    json.id "private_event_#{private_event.id}"
    
    json.extract! private_event, :patient_id, :nurse_id, :edit_requested, :title
    json.start private_event.starts_at.try(:strftime, date_format)
    json.end private_event.ends_at.try(:strftime, date_format)
    json.description private_event.description ? private_event.description : ''
    json.serviceType private_event.title || ''

    json.patient do 
        json.name private_event.patient.try(:name)
        json.address private_event.patient.try(:address)
    end

    json.eventType 'private_event'
    json.eventId private_event.id

    json.resourceIds ["nurse_#{private_event.nurse_id}", "patient_#{private_event.patient_id}"]

    json.nurse do 
        json.name private_event.nurse.try(:name)
    end

    json.color '#ff7777'
end