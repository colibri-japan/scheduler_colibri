module NursesHelper

    def from_seconds_to_hours_minutes(seconds)
        unless seconds.nil? || seconds == 0
            minutes = (seconds / 60) % 60 
            hours = seconds / (60 * 60)

            format("%02d:%02d", hours, minutes)
        else
            ''
        end

    end

    def nurse_availability_icon(count)
        case 
        when count <= 2
            '✕'
        when count.between?(3,4)
            '△'
        when count >= 5
            '○'
        else
            ''
        end
    end
end
