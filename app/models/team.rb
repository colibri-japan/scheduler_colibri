class Team < ApplicationRecord
  belongs_to :corporation
  has_many :nurses
end
