class CarePlan < ApplicationRecord
    belongs_to :care_manager
    belongs_to :patient

    scope :valid_at, -> date { where('kaigo_certification_validity_start <= ? AND kaigo_certification_validity_end >= ?', date, date) }
end
