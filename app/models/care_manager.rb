class CareManager < ApplicationRecord
    belongs_to :care_manager_corporation
    has_many :patients
end
