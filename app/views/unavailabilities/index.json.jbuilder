json.array!(@unavailabilities) do |unavailability|
json.id "unavailability_#{unavailability.id}"
json.extract! unavailability, :title, :description, :start, :end
json.resourceId unavailability.nurse_id
json.rendering 'background'

json.base_url planning_unavailability_url(@planning, unavailability)
json.edit_url edit_planning_unavailability_url(@planning, unavailability)
json.update_url planning_unavailability_url(@planning, unavailability, method: :patch)
end