module ActivitiesHelper

	def activity_creation_date(activity)
		if activity.created_at.day == Date.today.day
			activity.created_at.strftime("今日 %H:%M")
		else
			activity.created_at.strftime("%d日 %H:%M")
		end
	end

	def activity_icon(activity)
		if activity.key.include? "create"
			'create_32px.png'
		elsif activity.key.include? "update"
			'update_32px.png'
		elsif activity.key.include? "destroy"
			'destroy_32px.png'
		else
			' '
		end
	end

end
