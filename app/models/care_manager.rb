class CareManager < ApplicationRecord
    belongs_to :care_manager_corporation, touch: true
    has_many :care_plans
    has_many :patients 
    #maintaining existing relation, but will be moved to has many patients through care plans
    #has_many :patients, through: :care_plans

    before_destroy :remove_reference_from_patients

    private

    def remove_reference_from_patients
        self.patients.update_all(care_manager_id: nil)
    end

end
