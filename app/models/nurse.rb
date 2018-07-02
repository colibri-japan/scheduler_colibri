class Nurse < ApplicationRecord
	belongs_to :corporation
	has_many :appointments
	has_many :recurring_appointments
	has_many :provided_services

	validates :name, presence: true

end
