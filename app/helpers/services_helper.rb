module ServicesHelper

    def hour_based_wage_text(hour_based)
        hour_based ? '時給' : '単価'
    end
    
end