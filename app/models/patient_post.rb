class PatientPost < ApplicationRecord
  belongs_to :patient
  belongs_to :post
end
