module ServicesHelper

    SERVICE_CATEGORIES = [['訪問介護',11], ['訪問看護',13], ['訪問入浴介護',12], ['訪問リハビリテーション',14], ['介護予防訪問看護',63], ['介護予防訪問リハビリテーション',64], ['訪問型サービス（独自）',102], ['訪問型サービス（独自／定率）',103], ['訪問型サービス（独自／定額）',104]]

    SERVICE_CATEGORIES_FOR_NURSING = [['身体', 0], ['生活', 1], ['自費', 2],  ['障身', 3], ['障家', 8], ['総合', 9], ['リハ', 4], ['看護', 5], ['医療', 6], ['その他', 7]]
    SERVICE_CATEGORIES_FOR_STAFFING = [['就職カウンセリング', 10], ['その他', 11]]

    def hour_based_wage_text(hour_based)
        hour_based ? '時給' : '単価'
    end

    def invoicing_field_by_vertical(business_vertical)
        case business_vertical
        when 'elderly_care_and_nursing'
            '単位数'
        when 'temporary_staffing'
            '単価'
        else
            "事業所"
        end
    end

    def insurance_category_name(insurance_category_id)
        case insurance_category_id
        when 11
            '訪問介護'
        when 12
            '訪問入浴介護'
        when 13
            '訪問看護'
        when 14
            '訪問リハビリテーション'
        when 63
            '介護予防訪問看護'
        when 64
            '介護予防訪問リハビリテーション'
        when 102
            '訪問型サービス（独自）'
        when 103
            '訪問型サービス（独自／定率）'
        when 104
            '訪問型サービス（独自／定率）'
        else
            ''
        end
    end
    
end