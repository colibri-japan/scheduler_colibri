module AppointmentsHelper

    def from_seconds_to_hours_minutes(seconds)
        if seconds.present?
            minutes = (seconds / 60) % 60 
            hours = seconds / (60 * 60)

            format("%02d:%02d", hours, minutes)
        else
            '00:00'
        end

    end

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

    
    def weekend_holiday_appointment_css(appointment)
        if HolidayJp.holiday?(appointment.starts_at.to_date) || appointment.starts_at.wday == 0
            "sunday-holiday-provided-service"
        elsif appointment.starts_at.wday == 6
            "saturday-provided-service"
        else
            ''
        end
    end

    def care_manager_name(appointment)
        if appointment.patient.try(:care_managers).try(:last).try(:name).present?
            appointment.patient.try(:care_managers).try(:last).try(:name)
        else
            ""
        end
    end

    def appointment_title_in_excel(appointment)
        appointment.cancelled? ? "(キャンセル)" : appointment.try(:title)
    end

    def appointment_was_as_second_nurse(was_second_nurse)
        "（同行）" if was_second_nurse
    end

    def appointment_wage_with_nurse_status(appointment, nurse_id)
        if appointment.with_second_nurse_id?(nurse_id)
            "#{appointment.second_nurse_wage}¥"
        else
            "#{appointment.total_wage}¥"
        end
    end

    def credits_if_applicable(appointment)
        if !appointment.cancelled? && appointment.service.try(:credit_calculation_method) == 0
            appointment.total_credits || 0
        else
            0
        end
    end

    def appointment_resource_name(appointment, resource_type)
        if resource_type === 'patient'
            appointment.nurse.try(:name)
        else
            "#{appointment.patient.try(:name)}様"
        end
    end

    def batch_action_title(action_type)
        case action_type
        when 'cancel'
            'キャンセルするサービスの確認'
        when 'edit_requested'
            '調整中リスト追加の確認'
        when 'archive'
            '削除するサービスの確認'
        when 'restore_to_operational'
            '調整中・キャンセルの解除'
        else
            ''
        end
    end

    def batch_action_url(action_type)
        case action_type
        when 'cancel'
            appointments_batch_cancel_path
        when 'edit_requested'
            appointments_batch_request_edit_path
        when 'archive'
            appointments_batch_archive_path
        when 'restore_to_operational'
            appointments_batch_restore_to_operational_path
        else
            ''
        end
    end

    def batch_action_submit_title(action_type)
        case action_type
        when 'cancel'
            'キャンセル'
        when 'edit_requested'
            '調整中へ'
        when 'archive'
            '削除する'
        when 'restore_to_operational'
            '調整中とキャンセルの解除'
        else
            ''
        end
    end

    def batch_action_submit_style(action_type)
        case action_type
        when 'cancel'
            'btn-danger'
        when 'edit_requested'
            'btn-success'
        when 'archive'
            'btn-secondary'
        when 'restore_to_operational'
            'btn-info'
        else
            ''
        end
    end

end
