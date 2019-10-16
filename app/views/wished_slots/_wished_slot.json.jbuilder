slots = wished_slot.wished_slot_occurrences(params[:start], params[:end])

json.array! slots do |slot|
	json.allDay wished_slot.all_day?
	date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "wished_slot_#{wished_slot.id}"
	json.title wished_slot.title_from_rank
	json.extract! wished_slot, :frequency, :rank, :nurse_id
	json.description wished_slot.description || ''
	json.master true
	json.cancelled false
	json.start DateTime.new(slot.year, slot.month, slot.day, wished_slot.starts_at.hour, wished_slot.starts_at.min).strftime(date_format)
	json.end (DateTime.new(slot.year, slot.month, slot.day, wished_slot.ends_at.hour, wished_slot.ends_at.min) + wished_slot.duration.to_i).strftime(date_format)
	json.resourceId "nurse_#{wished_slot.nurse_id}"
	json.serviceType wished_slot.title_from_rank || ''
	json.nurse do
		json.name wished_slot.nurse.try(:name)
	end
	json.unavailability false 
	json.rendering 'background' if params[:background] == 'true'
	json.className background_wished_slot_css(wished_slot)
	json.borderColor wished_slot.color_from_rank unless params[:background] == 'true'
	json.eventType 'wished_slot'
	json.eventId wished_slot.id
end