module NursesHelper

    def from_seconds_to_hours_minutes(seconds)
        minutes = (seconds / 60) % 60 
        hours = seconds / (60 * 60)

        format("%02d:%02d", hours, minutes)
    end
end
