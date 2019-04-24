module AppointmentsHelper

    def date_and_time(appointment)
        "#{appointment.starts_at.strftime('%-m月%-d日')} #{appointment.starts_at.strftime('%-H:%M')} ~ #{appointment.ends_at.strftime('%-H:%M')}"
    end

    def confirm_cancel_message(appointment)
        appointment.cancelled ? "サービスのキャンセルが解除されます" : "サービスがキャンセルされます"
    end

    def confirm_request_edit_message(appointment)
        appointment.edit_requested ? '調整中を解除しますか？' : 'サービスが調整中リストへ追加されます'
    end

	def toggle_cancel_text(record)
		record.cancelled ? 'キャンセル解消' : 'キャンセル'
	end

	def toggle_edit_requested_text(record)
		record.edit_requested ? '調整中解除' : '調整中リストへ'
    end
    
    def completion_report_url_helper(appointment)
        if appointment.completion_report.present?
            edit_appointment_completion_report_path(appointment, appointment.completion_report)
        else
            new_appointment_completion_report_path(appointment)
        end
    end

    def completion_report_text(appointment)
        appointment.completion_report.present? ? "実施記録へ" :  "+実施記録"
    end

end
