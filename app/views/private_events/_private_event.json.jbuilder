date_format = private_event.all_day_private_event? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id "private_event_#{private_event.id}"

json.extract! private_event, :patient_id, :nurse_id, :edit_requested
json.title "#{private_event.patient.try(:name)} #{private_event.nurse.try(:name)}: #{private_event.title}"
json.start private_event.starts_at
json.end private_event.ends_at
json.description private_event.description ? private_event.description : ''
json.service_type private_event.title ? private_event.title : ''

json.allDay private_event.all_day_private_event? ? true : false

json.private_event true
json.patient do 
    json.name private_event.patient.try(:name)
    json.address private_event.patient.try(:address)
end

json.eventType 'private_event'

json.resourceId private_event.nurse_id

json.displayable true

if private_event.nurse_id.present?
    json.nurse do 
        json.name private_event.nurse.try(:name)
    end
end

json.color '#ff7777'

json.base_url planning_private_event_path(@planning, private_event)
json.edit_url edit_planning_private_event_path(@planning, private_event)

