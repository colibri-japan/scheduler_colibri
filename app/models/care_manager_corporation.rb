class CareManagerCorporation < ApplicationRecord

    belongs_to :corporation
    has_many :care_managers, dependent: :destroy

    scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }

    def teikyohyo_data(first_day, last_day)
        # issue here, change in relation between care manager corporation and patients
        #patients = Patient.where(care_manager_id: self.care_managers.ids).still_active_at(first_day.to_date).order_by_kana
        care_plans = CarePlan.where(care_manager_id: self.care_managers.ids).valid_at(first_day.to_date)
        patients = Patient.where(id: care_plans.pluck(:patient_id).uniq.compact).still_active_at(first_day.to_date)

        services_and_shifts_per_patient = {}
        care_plans_per_patient = {}

        if patients.present?
            patients.each do |patient|
                services_and_shifts_per_patient[patient] = patient.invoicing_summary(first_day..last_day)
                care_plans_per_patient[patient] = {current_plan: patient.care_plans.valid_at(first_day.to_date).first, previous_plan: patient.care_plans.valid_at(first_day.to_date - 1.month).first}
            end
        end

        {invoicing_summary_per_patient: services_and_shifts_per_patient, care_plans: care_plans_per_patient}
    end
end
