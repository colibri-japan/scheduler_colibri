class CarePlan < ApplicationRecord
    belongs_to :care_manager
    belongs_to :patient
end
