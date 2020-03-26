class CarePlan < ApplicationRecord
    belongs_to :care_manager, optional: true
    belongs_to :patient
    belongs_to :attending_nurse, optional: true

    scope :valid_at, -> date { where('kaigo_certification_validity_start <= ? AND kaigo_certification_validity_end >= ?', date, date) }
end
