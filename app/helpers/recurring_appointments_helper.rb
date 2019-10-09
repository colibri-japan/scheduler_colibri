module RecurringAppointmentsHelper

    def url_for_recurring_completion_report(recurring_appointment)
        if recurring_appointment.completion_report.present?
            edit_recurring_appointment_completion_report_path(recurring_appointment, recurring_appointment.completion_report)
        else
            new_recurring_appointment_completion_report_path(recurring_appointment)
        end
    end

end
