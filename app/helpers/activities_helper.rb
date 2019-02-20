module ActivitiesHelper

	def activity_icon(activity)
		if activity.key.include? "create"
			'create_32px.png'
		elsif activity.key.include? "update"
			'update_32px.png'
		elsif activity.key.include? "destroy"
			'destroy_32px.png'
		elsif activity.key.include? "terminate"
			'destroy_32px.png'
		elsif activity.key.include? "toggle_edit_requested"
			'edit_requested_32px.png'
		elsif activity.key.include? "archive"
			'destroy_32px.png'
		elsif activity.key.include? "toggle_cancelled"
			'cancel_32px.png'
		else
			' '
		end
	end

end
