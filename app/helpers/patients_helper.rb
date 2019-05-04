module PatientsHelper

    def gender_text(patient)
        patient.gender ? '女' : '男'
    end

    def maximum_budget(patient)
        case patient.kaigo_level
        when 7
            ''
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
        end
    end

    def kaigo_level_text(patient)
        case patient.kaigo_level
        when 7
            '申請中'
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
        end
    end

    def kaigo_certification_validity(patient)
        if patient.present?
            "#{patient.kaigo_certification_validity_start.try(:strftime, "%Jf")} ~ \x0A #{patient.kaigo_certification_validity_end.try(:strftime, "%Jf")}"
        else
            ""
        end
    end
end
