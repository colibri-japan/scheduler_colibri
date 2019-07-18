class NurseServiceWage < ApplicationRecord
    belongs_to :service 
    belongs_to :nurse

    validates_uniqueness_of :nurse_id, scope: :service_id
end
