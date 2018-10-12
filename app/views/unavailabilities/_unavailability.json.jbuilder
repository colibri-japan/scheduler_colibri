date_format = unavailability.all_day_unavailability? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id "unavailability_#{unavailability.id}"

json.extract! unavailability, :start, :end, :patient_id, :edit_requested
json.description unavailability.description ? unavailability.description : ''
json.service_type unavailability.title ? unavailability.title : ''
json.title "#{unavailability.patient.try(:name)}: #{unavailability.title}" 

json.allDay unavailability.all_day_unavailability? ? true : false

json.unavailability true

json.color '#D46A6A'

json.base_url planning_unavailability_path(@planning, unavailability)
json.edit_url edit_planning_unavailability_path(@planning, unavailability)
json.update_url planning_unavailability_path(@planning, unavailability, method: :patch)

