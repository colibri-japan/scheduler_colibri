date_format = unavailability.all_day_unavailability? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id "unavailability_#{unavailability.id}"
json.title "#{unavailability.patient.try(:name)}: #{unavailability.title}" 

json.extract! unavailability, :description, :start, :end

json.allDay unavailability.all_day_unavailability? ? true : false
json.patientId unavailability.patient_id
json.editRequested unavailability.edit_requested

json.color '#D46A6A'

json.base_url planning_unavailability_path(@planning, unavailability)
json.edit_url edit_planning_unavailability_path(@planning, unavailability)
json.update_url planning_unavailability_path(@planning, unavailability, method: :patch)
