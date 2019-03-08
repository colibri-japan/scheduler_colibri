slots = wished_slot.wished_slot_occurrences(params[:start], params[:end])
json.array! slots do |slot|
	date_format = wished_slot.all_day_wished_slot? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "recurringUnavailability_#{wished_slot.id}"
	json.title wished_slot.title
	json.start DateTime.new(slot.year, slot.month, slot.day, wished_slot.starts_at.hour, wished_slot.starts_at.min)
	json.end DateTime.new(slot.year, slot.month, slot.day, wished_slot.ends_at.hour, wished_slot.ends_at.min)
	json.allDay wished_slot.all_day_wished_slot? ? true : false
	json.resourceId wished_slot.nurse_id
	json.color wished_slot.color_from_rank
	json.unavailability false 

	json.base_url planning_wished_slot_path(@planning, wished_slot)
	json.update_url planning_wished_slot_path(@planning, wished_slot, method: :patch)
	json.edit_url edit_planning_wished_slot_path(@planning, wished_slot)
end