class Patient < ApplicationRecord
	acts_as_taggable
	acts_as_taggable_on :caveats

	has_many :appointments
	has_many :recurring_appointments
	has_many :unavailabilities
	has_many :recurring_unavailabilities
	has_many :provided_services
	belongs_to :corporation
	
	validates :name, presence: true

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :active, -> { where(active: true) }

end
