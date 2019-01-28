module AppointmentsHelper

    def date_and_time(appointment)
        "#{appointment.starts_at.strftime('%-m月%-d日')} #{appointment.starts_at.strftime('%-H:%M')} ~ #{appointment.ends_at.strftime('%-H:%M')}"
    end

    def confirm_cancel_message(appointment)
        appointment.cancelled == true ? "サービスのキャンセルが解除されます" : "サービスがキャンセルされます"
    end

	def toggle_cancel_text(record)
		record.cancelled ? 'キャンセル解消' : 'キャンセルする'
	end

	def toggle_edit_requested_text(record)
		record.edit_requested ? '調整中解除' : '調整中リストへ'
	end

end
