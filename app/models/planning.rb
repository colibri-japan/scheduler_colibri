class Planning < ApplicationRecord
	belongs_to :corporation
	has_many :appointments, dependent: :destroy
	has_many :recurring_appointments, dependent: :destroy
	has_many :unavailabilities, dependent: :destroy
	has_many :recurring_unavailabilities, dependent: :destroy
	has_many :provided_services, dependent: :destroy
end
