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
end
