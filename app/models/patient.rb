class Patient < ApplicationRecord
	has_many :appointments
	has_many :recurring_appointments
	belongs_to :corporation
	
	validates :name, presence: true

end
