module ActivitiesHelper

	def activity_icon(activity_key)
		if activity_key.include? "create"
			'create.svg'
		elsif activity_key.include? "update"
			'edit_icon.svg'
		elsif activity_key.include? "destroy"
			'delete_icon.svg'
		elsif activity_key.include? "terminate"
			'delete_icon.svg'
		elsif activity_key.include? "toggle_edit_requested"
			'edit_requested_icon.svg'
		elsif activity_key.include? "archive"
			'delete_icon.svg'
		elsif activity_key.include? "toggle_cancelled"
			'cancel.svg'
		elsif activity_key.include? "batch_request_edit"
			'edit_requested_icon.svg'
		elsif activity_key.include? "batch_cancel"
			'cancel.svg'
		elsif activity_key.include? "batch_archive"
			'delete_icon.svg'
		elsif activity_key.include? "reflect_all_master"
			'duplicate_icon.svg'
		elsif activity_key.include? "reflect_nurse_master"
			'duplicate_icon.svg'
		elsif activity_key.include? "reflect_patient_master"
			'duplicate_icon.svg'
		else
			' '
		end
	end

	def toggle_cancelled_activity_text(was_cancelled)
		was_cancelled ? 'サービスのキャンセルを解除しました' : 'サービスをキャンセルしました'
	end

	def changed_cancelled_text(was_cancelled)
		was_cancelled ? '> キャンセル解除' : '> キャンセル'
	end

	def changed_edit_requested_text(edit_was_requested)
		edit_was_requested ? "> 調整中リストから出す" :  "> 調整中リストへ追加"
	end

end
