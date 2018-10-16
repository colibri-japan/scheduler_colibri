module DashboardHelper
    def patient_gender(patient)
        patient.gender ? '女' : '男'
    end
end
