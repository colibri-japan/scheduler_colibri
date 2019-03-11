slots = wished_slot.wished_slot_occurrences(params[:start], params[:end])
puts 'printing params start and end'
puts params[:start]
puts params[:end]
json.array! slots do |slot|
	puts 'printing each slot:'
	puts slot
	json.allDay wished_slot.all_day_wished_slot?
	date_format = json.allDay ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
	json.id "wished_slot_#{wished_slot.id}"
	json.title wished_slot.title_from_rank
	json.extract! wished_slot, :frequency, :rank, :nurse_id
	json.description wished_slot.description || ''
	json.master true
	json.cancelled false
	json.displayable true
	json.start DateTime.new(slot.year, slot.month, slot.day, wished_slot.starts_at.hour, wished_slot.starts_at.min)
	json.end DateTime.new(slot.year, slot.month, slot.day, wished_slot.ends_at.hour, wished_slot.ends_at.min) + wished_slot.duration.to_i
	json.resourceId wished_slot.nurse_id
	json.private_event false
	json.service_type wished_slot.title_from_rank
	json.nurse do
		json.name wished_slot.nurse.try(:name)
	end
	json.unavailability false 
	json.rendering 'background' if params[:background] == 'true'
	json.className background_wished_slot_css(wished_slot)

	json.base_url planning_wished_slot_path(@planning, wished_slot)
	json.update_url planning_wished_slot_path(@planning, wished_slot, method: :patch)
	json.edit_url edit_planning_wished_slot_path(@planning, wished_slot)
end