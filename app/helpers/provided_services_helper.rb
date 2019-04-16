module ProvidedServicesHelper

    def provided_service_title_with_counts(provided_service)
        provided_service.service_counts == 1 ?  provided_service.try(:title) : "#{provided_service.try(:title)}(x#{provided_service.service_counts})"
    end

    def provided_service_title_in_excel(provided_service)
        if provided_service.cancelled == true 
            "#{provided_service.try(:title)} (キャンセル)"
        else
            provided_service.service_counts == 1 ?  provided_service.try(:title) : "#{provided_service.try(:title)}(x#{provided_service.service_counts})"
        end
    end

    def weekend_holiday_provided_service_css(provided_service)
        if HolidayJp.between(provided_service.service_date.beginning_of_day, provided_service.service_date.end_of_day).present? || provided_service.service_date.wday == 0
            "sunday-holiday-provided-service"
        elsif provided_service.service_date.wday == 6
            "saturday-provided-service"
        end
    end

    def category_name_by_key(category_key)
        case category_key
        when 0
            "身体"
        when 1
            "生活"
        when 2
            "自費"
        when 3
            "障害"
        when 4
            "リハ"
        when 5
            "看護"
        when 6
            "医療"
        when 7
            "その他"
        else
            ""
        end
    end
end