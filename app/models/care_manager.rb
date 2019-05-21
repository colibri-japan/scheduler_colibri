class CareManager < ApplicationRecord
    belongs_to :care_manager_corporation
    has_many :patients

    before_destroy :remove_reference_from_patients

    private

    def remove_reference_from_patients
        self.patients.update_all(care_manager_id: nil)
    end

end
