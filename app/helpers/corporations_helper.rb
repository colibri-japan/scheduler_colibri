module CorporationsHelper

    def corporation_bonus_text(corporation)
        case corporation.invoicing_bonus_ratio
        when 1
            "加算なし"
        when 1.055
            "処遇改善加算I - 5.5%"
        when 1.1
            "処遇改善加算II - 10%"
        when 1.137
            "処遇改善加算III - 13.7%"
        else
        end
    end

    def corporation_resource_name(business_vertical)
        case business_vertical
        when 'elderly_care_and_nursing'
            "事業所"
        when 'temporary_staffing'
            "企業"
        else
            "事業所"
        end
    end

    def service_categories_by_vertical(business_vertical)
        case business_vertical
        when 'elderly_care_and_nursing'
            ServicesHelper::SERVICE_CATEGORIES_FOR_NURSING
        when 'temporary_staffing'
            ServicesHelper::SERVICE_CATEGORIES_FOR_STAFFING
        else
            "事業所"
        end
    end

    def corporation_bonus_official_text(corporation, insurance_category_id)
        if insurance_category_id == 11
            case corporation.invoicing_bonus_ratio
            when 1
                ""
            when 1.055
                "訪問介護処遇改善加算III"
            when 1.1
                "訪問介護処遇改善加算II"
            when 1.137
                "訪問介護処遇改善加算I"
            else
            end
        elsif insurance_category_id == 102
            case corporation.invoicing_bonus_ratio
            when 1
                ""
            when 1.055
                "訪問型独自処遇改善加算III"
            when 1.1
                "訪問型独自処遇改善加算II"
            when 1.137
                "訪問型独自処遇改善加算I"
            else
            end
        else
        end
    end

    def corporation_bonus_service_code(corporation, insurance_category_id)
        if insurance_category_id == 11
            case corporation.invoicing_bonus_ratio
            when 1
                ""
            when 1.055
                "116275"
            when 1.1
                "116275"
            when 1.137
                "116275"
            else
            end
        elsif insurance_category_id == 102
            case corporation.invoicing_bonus_ratio
            when 1
                ""
            when 1.055
                "A26271"
            when 1.1
                "A26270"
            when 1.137
                "A26269"
            else
            end
        else
        end
    end
end
