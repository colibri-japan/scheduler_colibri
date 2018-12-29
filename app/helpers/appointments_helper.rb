module AppointmentsHelper

    def date_and_time(appointment)
        "#{appointment.starts_at.strftime('%Y年%m月%d日')} #{appointment.starts_at.strftime("%h:%M")} ~ #{appointment.ends_at.strftime("%h:%M")}"
    end

end
