class Planning < ApplicationRecord
	belongs_to :corporation
	has_many :appointments, dependent: :destroy
	has_many :recurring_appointments, dependent: :destroy
	has_many :private_events, dependent: :destroy
	has_many :wished_slots, dependent: :destroy
	has_many :provided_services, dependent: :destroy
	has_many :scans, dependent: :destroy

	before_save :default_title

	private

	def default_title
		self.title = "#{self.business_month}月のスケジュール" if self.title.blank?
	end

end
