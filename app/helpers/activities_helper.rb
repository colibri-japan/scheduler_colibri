module ActivitiesHelper

	def activity_icon(activity_key)
		if activity_key.include? "create"
			'create_32px.png'
		elsif activity_key.include? "update"
			'update_32px.png'
		elsif activity_key.include? "destroy"
			'destroy_32px.png'
		elsif activity_key.include? "terminate"
			'destroy_32px.png'
		elsif activity_key.include? "toggle_edit_requested"
			'edit_requested_32px.png'
		elsif activity_key.include? "archive"
			'destroy_32px.png'
		elsif activity_key.include? "toggle_cancelled"
			'cancel_32px.png'
		elsif activity_key.include? "batch_request_edit"
			'edit_requested_32px.png'
		elsif activity_key.include? "batch_cancel"
			'cancel_32px.png'
		elsif activity_key.include? "batch_archive"
			'destroy_32px.png'
		else
			' '
		end
	end

end
