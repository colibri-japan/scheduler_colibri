class Planning < ApplicationRecord
	belongs_to :corporation
	has_many :appointments
	has_many :recurring_appointments

end
