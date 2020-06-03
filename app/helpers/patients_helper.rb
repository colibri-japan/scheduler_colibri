module PatientsHelper

    def client_resource_name(business_vertical)
        case business_vertical
        when 'temporary_staffing'
            "顧客"
        else
            "利用者"
        end
    end

    def gender_text(gender)
        if gender == 1
            '男'
        elsif gender == 2
            '女'
        else
            ''
        end
    end

    def short_kaigo_level(kaigo_level)
        case kaigo_level
        when 12
            '支1'
        when 13
            '支2'
        when 21
            '介1'
        when 22
            '介2'
        when 23
            '介3'
        when 24
            '介4'
        when 25
            '介5'
        else 
            ''
        end
    end

    def maximum_budget(kaigo_level)
        case kaigo_level
        when 12
            '5,003単位'
        when 13
            '10,473単位'
        when 21
            '16,692単位'
        when 22
            '19,616単位'
        when 23
            '26,931単位'
        when 24
            '30,806単位'
        when 25
            '36,065単位'
        else 
            ''
        end
    end

    def kaigo_level_text(kaigo_level)
        case kaigo_level
        when 12
            '要支援１'
        when 13
            '要支援２'
        when 21
            '要介護１'
        when 22
            '要介護２'
        when 23
            '要介護３'
        when 24
            '要介護４'
        when 25
            '要介護５'
        when 6
            '事業対象者'
        else 
            ' - '
        end
    end

    def first_care_manager_corporation_title(kaigo_level)
        if [6,12,13].include?(kaigo_level)
            '担当地域包括'
        else
            '居宅介護事業所'
        end
    end

    def first_care_manager_corporation_name(care_plan)
        return '' if care_plan.nil?

        if [6,12,13].include?(care_plan.try(:kaigo_level))
            if care_plan.care_manager.present? && care_plan.second_care_manager.present?
                care_plan.second_care_manager.try(:care_manager_corporation).try(:name)
            elsif care_plan.care_manager.present?
                care_plan.care_manager.try(:care_manager_corporation).try(:name)
            elsif care_plan.second_care_manager.present? 
                care_plan.second_care_manager.try(:care_manager_corporation).try(:name)
            end
        else
            if care_plan.care_manager.present?
                care_plan.care_manager.try(:care_manager_corporation).try(:name)
            else
                ''
            end
        end
    end
    
    def first_care_manager_name(care_plan)
        return '' if care_plan.nil? 
        
        if [6,12,13].include?(care_plan.kaigo_level)
            if care_plan.care_manager.present? && care_plan.second_care_manager.present?
                care_plan.second_care_manager.try(:name)
            elsif care_plan.care_manager.present?
                care_plan.care_manager.try(:name)
            elsif care_plan.second_care_manager.present? 
                care_plan.second_care_manager.try(:name)
            end
        else
            care_plan.care_manager.try(:name)
        end
    end

    def second_care_manager_corporation_title(kaigo_level)
        if [6,12,13].include?(kaigo_level)
            '居宅介護事業所'
        else
            '保険者確認印'
        end
    end

    def second_care_manager_corporation_name(care_plan)
        if [6,12,13].include?(care_plan.try(:kaigo_level))
            if care_plan.care_manager.present? && care_plan.second_care_manager.present?
                "#{care_plan.care_manager.try(:care_manager_corporation).try(:name)}<br/>#{care_plan.care_manager.try(:name)}".html_safe
            elsif care_plan.care_manager.present?
                ''
            elsif care_plan.second_care_manager.present? 
                ''
            end
        else
            ''
        end
    end

    def kaigo_certification_validity(patient)
        if patient.present?
            "#{patient.kaigo_certification_validity_start.try(:to_jp_date)} ~ \x0A #{patient.kaigo_certification_validity_end.try(:to_jp_date)}"
        else
            ""
        end
    end

    def day_count_for_hiwari_service(day_count)
        if day_count == 0
            "<div class='btn btn-sm btn-info edit_hiwari_count'>+日数計算</div>".html_safe
        else
            "#{day_count} <span class='glyphicon glyphicon-pencil btn-pointer edit_hiwari_count' style='font-size:15px;color:#4f5b66;margin-left:4px'></span>".html_safe
        end
    end
end
