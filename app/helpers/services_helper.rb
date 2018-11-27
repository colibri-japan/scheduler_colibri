module ServicesHelper

    def humanize_hour_based_wage(service)
        service.hour_based_wage ? '時給' : '単価'
    end

    def humanize_equal_salary(service)
        service.equal_salary ? '全員同じ' : 'ヘルパー別'
    end
    
end