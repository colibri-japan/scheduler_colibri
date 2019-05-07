class CareManagerCorporation < ApplicationRecord

    belongs_to :corporation
    has_many :care_managers

    def teikyohyo_data
    end

    private

end
