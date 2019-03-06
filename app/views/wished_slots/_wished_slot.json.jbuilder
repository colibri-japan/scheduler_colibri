slots = wished_slot.wished_slot_occurrences(params[:start], params[:end])
json.array! slots do |slot|
	date_format = wished_slot.all_day_recurring_unavailability? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "recurringUnavailability_#{wished_slot.id}"
	json.title wished_slot.title
	json.start DateTime.new(slot.year, slot.month, slot.day, slot.starts_at.hour, slot.starts_at.min)
	json.end DateTime.new(slot.year, slot.month, slot.day, slot.ends_at.hour, slot.ends_at.min)
	json.allDay wished_slot.all_day_wished_slot? ? true : false
	json.resourceId wished_slot.nurse_id
	json.color '#D46A6A'

	json.base_url planning_recurring_unavailability_path(@planning, wished_slot)
	json.update_url planning_recurring_unavailability_path(@planning, wished_slot, method: :patch)
	json.edit_url edit_planning_recurring_unavailability_path(@planning, wished_slot)
end