module ServicesHelper

    SERVICE_CATEGORIES = [['訪問介護',11], ['訪問看護',13], ['訪問入浴介護',12], ['訪問リハビリテーション',14], ['介護予防訪問看護',63], ['介護予防訪問リハビリテーション',64], ['訪問型サービス（独自）',102], ['訪問型サービス（独自／定率）',103], ['訪問型サービス（独自／定率）',104]]

    def hour_based_wage_text(hour_based)
        hour_based ? '時給' : '単価'
    end
    
end