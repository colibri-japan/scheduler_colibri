module DashboardHelper
    def patient_gender(patient)
        patient.try(:gender) ? '女' : '男'
    end
end
