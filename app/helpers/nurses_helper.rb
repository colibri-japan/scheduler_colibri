module NursesHelper

    def from_seconds_to_hours_minutes(seconds)
        minutes = (seconds / 60) % 60 
        hours = seconds / (60 * 60)

        format("%02d:%02d", hours, minutes)
    end

    def provided_service_title_in_excel(provided_service)
        if provided_service.cancelled == true 
            "#{provided_service.try(:title)} (キャンセル)"
        else
            provided_service.try(:title)
        end
    end
end
