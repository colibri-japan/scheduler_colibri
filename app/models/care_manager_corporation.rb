class CareManagerCorporation < ApplicationRecord

    belongs_to :corporation
    has_many :care_managers, dependent: :destroy

    def teikyohyo_data(first_day, last_day)
        patients = Patient.where(care_manager_id: self.care_managers.ids).still_active_at(first_day.to_date)

        services_and_shifts_per_patient = {}

        patients.each do |patient|
            array_of_service_shifts_hashes = []

            array_of_services_hash = patient.appointments_summary(first_day..last_day, within_insurance_scope: true)

            array_of_services_hash.each do |service_hash|
                shifts_by_service_hash = {}
                shifts_by_service_hash[:service_hash] = service_hash
                shifts_by_service_hash[:shifts_hash] = patient.shifts_by_title_and_date_range(service_hash[:title], first_day..last_day)                
                array_of_service_shifts_hashes << shifts_by_service_hash
            end
            services_and_shifts_per_patient[patient] = array_of_service_shifts_hashes
        end

        services_and_shifts_per_patient
    end

    private

end
