module CalendarEvent
    extend ActiveSupport::Concern

    included do
        validates :starts_at, presence: true
        validates :ends_at, presence: true
    end

    def on_weekend_or_holiday?
        !starts_at.on_weekday? || !ends_at.on_weekday? || HolidayJp.between(starts_at, ends_at).present?
    end

    def all_day?
        starts_at == starts_at.midnight && ends_at == ends_at.midnight
    end


end