module NursesHelper

    def from_seconds_to_hours_minutes(seconds)
        minutes = (seconds / 60) % 60 
        hours = seconds / (60 * 60)

        format("%02d:%02d", hours, minutes)
    end

    def nurse_availability_icon(count)
        case 
        when count == 0
            '✕'
        when count == 1
            '△'
        when count == 2
            '○'
        when count >= 3
            '◎'
        else
            ''
        end
    end
end
