module ServicesHelper

    def humanize_hour_based_wage(service)
        service.hour_based_wage ? '時給' : '単価'
    end
    
end