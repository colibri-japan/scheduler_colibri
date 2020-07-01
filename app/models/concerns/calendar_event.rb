module CalendarEvent
    extend ActiveSupport::Concern

    def on_weekend_or_holiday?
        !starts_at.on_weekday? || HolidayJp.between(starts_at, ends_at).present?
    end

    def all_day?
        starts_at == starts_at.midnight && ends_at == ends_at.midnight
    end


end