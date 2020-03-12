module RecurringAppointmentsHelper

    def url_for_recurring_completion_report(recurring_appointment, date_params)
        if recurring_appointment.completion_report.present?
            edit_recurring_appointment_completion_report_path(recurring_appointment, recurring_appointment.completion_report, date: date_params)
        else
            new_recurring_appointment_completion_report_path(recurring_appointment)
        end
    end

end
