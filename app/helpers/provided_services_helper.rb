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
end