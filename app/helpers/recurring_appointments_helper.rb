module RecurringAppointmentsHelper

    def url_for_recurring_completion_report(recurring_appointment, date_params)
        date = date_params.to_date rescue Date.today
        if recurring_appointment.completion_report.present?
            edit_recurring_appointment_completion_report_path(recurring_appointment, recurring_appointment.completion_report, date: date_params, start: date, end: (date.end_of_month + 14.days))
        else
            new_recurring_appointment_completion_report_path(recurring_appointment, start: date, end: (date.end_of_month + 14.days))
        end
    end

end
