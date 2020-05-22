class CarePlan < ApplicationRecord
    belongs_to :care_manager, optional: true
    belongs_to :second_care_manager, optional: true, class_name: 'CareManager'
    belongs_to :patient
    belongs_to :attending_nurse, optional: true

    scope :valid_at, -> date { where('kaigo_certification_validity_start <= ? AND kaigo_certification_validity_end >= ?', date, date) }

    before_save :clear_kaigo_and_handicap_levels_if_certification_is_pending

    private

    def clear_kaigo_and_handicap_levels_if_certification_is_pending
        if kaigo_certification_status == 1
            self.kaigo_level = nil
            self.handicap_level = nil
        end
    end

end
