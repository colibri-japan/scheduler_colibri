module PatientsHelper

    def client_resource_name(business_vertical)
        case business_vertical
        when 'elderly_care_and_nursing'
            "利用者"
        when 'temporary_staffing'
            "顧客"
        else
            "利用者"
        end
    end

    def gender_text(gender)
        gender ? '女' : '男'
    end

    def short_kaigo_level(kaigo_level)
        case kaigo_level
        when 0
            '支1'
        when 1
            '支2'
        when 2
            '介1'
        when 3
            '介2'
        when 4
            '介3'
        when 5
            '介4'
        when 6
            '介5'
        else 
            ''
        end
    end

    def maximum_budget(kaigo_level)
        case kaigo_level
        when 0
            '5,003単位'
        when 1
            '10,473単位'
        when 2
            '16,692単位'
        when 3
            '19,616単位'
        when 4
            '26,931単位'
        when 5
            '30,806単位'
        when 6
            '36,065単位'
        else 
            ''
        end
    end

    def kaigo_level_text(kaigo_level)
        case kaigo_level
        when 7
            '申請中'
        when 8
            '事業対象者'
        when 0
            '要支援1'
        when 1
            '要支援2'
        when 2
            '要介護1'
        when 3
            '要介護2'
        when 4
            '要介護3'
        when 5
            '要介護4'
        when 6
            '要介護5'
        else 
            ''
        end
    end

    def first_care_manager_corporation_title(kaigo_level)
        if [8,0,1].include?(kaigo_level)
            '担当地域包括'
        else
            '居宅介護事業所'
        end
    end

    def first_care_manager_corporation_name(patient)
        if [8,0,1].include?(patient.kaigo_level)
            if patient.care_manager.present? && patient.second_care_manager.present?
                patient.second_care_manager.care_manager_corporation.try(:name)
            elsif patient.care_manager.present?
                patient.care_manager.care_manager_corporation.try(:name)
            elsif patient.second_care_manager.present? 
                patient.second_care_manager.care_manager_corporation.try(:name)
            end
        else
            patient.care_manager.care_manager_corporation.name
        end
    end
    
    def first_care_manager_name(patient)
        if [8,0,1].include?(patient.kaigo_level)
            if patient.care_manager.present? && patient.second_care_manager.present?
                patient.second_care_manager.try(:name)
            elsif patient.care_manager.present?
                patient.care_manager.try(:name)
            elsif patient.second_care_manager.present? 
                patient.second_care_manager.try(:name)
            end
        else
            patient.care_manager.try(:name)
        end
    end

    def second_care_manager_corporation_title(kaigo_level)
        if [8,0,1].include?(kaigo_level)
            '居宅介護事業所'
        else
            '保険者確認印'
        end
    end

    def second_care_manager_corporation_name(patient)
        #not finished
        if [8,0,1].include?(patient.kaigo_level)
            if patient.care_manager.present? && patient.second_care_manager.present?
                "#{patient.care_manager.care_manager_corporation.try(:name)}<br/>#{patient.care_manager.try(:name)}".html_safe
            elsif patient.care_manager.present?
                ''
            elsif patient.second_care_manager.present? 
                ''
            end
        else
            ''
        end
    end

    def kaigo_certification_validity(patient)
        if patient.present?
            "#{patient.kaigo_certification_validity_start.try(:strftime, "%Jf")} ~ \x0A #{patient.kaigo_certification_validity_end.try(:strftime, "%Jf")}"
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
