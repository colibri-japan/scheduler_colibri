date_format = unavailability.all_day_unavailability? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id "unavailability_#{unavailability.id}"
json.extract! unavailability, :title, :description, :start, :end
json.resourceId unavailability.nurse_id

json.allDay unavailability.all_day_unavailability? ? true : false
json.rendering 'background' unless @nurse.present?

json.color '#D46A6A'

json.base_url planning_unavailability_url(@planning, unavailability)
json.edit_url edit_planning_unavailability_url(@planning, unavailability)
json.update_url planning_unavailability_url(@planning, unavailability, method: :patch)
