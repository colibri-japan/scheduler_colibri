class Patient < ApplicationRecord
	has_many :appointments
	has_many :recurring_appointments
	
	validates :name, presence: true

end
