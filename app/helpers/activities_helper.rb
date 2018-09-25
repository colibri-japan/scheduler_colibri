module ActivitiesHelper

	def activity_creation_date(activity)
		if activity.created_at.in_time_zone('Tokyo').day == Time.current.in_time_zone('Tokyo').day
			activity.created_at.in_time_zone('Tokyo').strftime("今日 %H:%M")
		else
			activity.created_at.in_time_zone('Tokyo').strftime("%d日 %H:%M")
		end
	end

	def activity_icon(activity)
		if activity.key.include? "create"
			'create_32px.png'
		elsif activity.key.include? "update"
			'update_32px.png'
		elsif activity.key.include? "destroy"
			'destroy_32px.png'
		elsif activity.key.include? "toggle_edit_requested"
			'edit_requested_32px.png'
		elsif activity.key.include? "archive"
			'destroy_32px.png'
		else
			' '
		end
	end

end
