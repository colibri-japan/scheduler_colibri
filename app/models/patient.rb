class Patient < ApplicationRecord
	has_many :appointments
	has_many :recurring_appointments
	has_many :unavailabilities
	has_many :recurring_unavailabilities
	has_many :provided_services
	belongs_to :corporation
	
	validates :name, presence: true

end
