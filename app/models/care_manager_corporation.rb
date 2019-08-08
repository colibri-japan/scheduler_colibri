class CareManagerCorporation < ApplicationRecord

    belongs_to :corporation
    has_many :care_managers, dependent: :destroy

    def teikyohyo_data(first_day, last_day)
        patients = Patient.where(care_manager_id: self.care_managers.ids).still_active_at(first_day.to_date)
        corporation = patients.first.corporation

        services_and_shifts_per_patient = {}

        patients.each do |patient|
            services_and_shifts_per_patient[patient] = patient.invoicing_summary(first_day..last_day)
        end

        services_and_shifts_per_patient
    end


end
