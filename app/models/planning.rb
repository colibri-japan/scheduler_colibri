class Planning < ApplicationRecord
	belongs_to :corporation
	has_many :appointments
	has_many :recurring_appointments
	has_many :private_events
	has_many :wished_slots
	has_many :provided_services

	before_save :default_title

	private

	def default_title
		self.title = "#{self.business_month}月のスケジュール" if self.title.blank?
	end

end
