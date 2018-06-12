module ActivitiesHelper

	def activity_creation_date(activity)
		if activity.created_at.day == Date.today
			activity.created_at.strftime("%H:%M")
		else
			activity.created_at.strftime("%d:%M")
		end
	end


end
