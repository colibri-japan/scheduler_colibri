module ActivitiesHelper

	def activity_creation_date(activity)
		if activity.created_at.day == Date.today.day
			activity.created_at.strftime("今日 %H:%M")
		else
			activity.created_at.strftime("%d日 %H:%M")
		end
	end

end
