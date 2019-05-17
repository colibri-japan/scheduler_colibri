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

    def corporation_bonus_official_text(corporation)
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
    end

    def corporation_bonus_service_code(corporation)
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
    end
end
