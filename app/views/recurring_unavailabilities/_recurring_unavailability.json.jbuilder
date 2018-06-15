unavailabilities = recurring_unavailability.unavailabilities(params[:start], params[:end])
json.array! unavailabilities do |unavailability|
	date_format = recurring_unavailability.all_day_recurring_unavailability? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "recurringUnavailability_#{recurring_unavailability.id}"
	json.title recurring_unavailability.title
	json.start DateTime.new(unavailability.year, unavailability.month, unavailability.day, recurring_unavailability.start.hour, recurring_unavailability.start.min)
	json.end DateTime.new(unavailability.year, unavailability.month, unavailability.day, recurring_unavailability.end.hour, recurring_unavailability.end.min)
	json.allDay recurring_unavailability.all_day_recurring_unavailability? ? true : false
	json.resourceId recurring_unavailability.nurse_id
	json.color '#D46A6A'
	json.rendering 'background' unless @nurse.present?

	json.base_url planning_recurring_unavailability_path(@planning, recurring_unavailability)
	json.update_url planning_recurring_unavailability_path(@planning, recurring_unavailability, method: :patch)
	json.edit_url edit_planning_recurring_unavailability_path(@planning, recurring_unavailability)
end