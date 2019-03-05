class Planning < ApplicationRecord
	belongs_to :corporation
	has_many :appointments, dependent: :destroy
	has_many :recurring_appointments, dependent: :destroy
	has_many :private_events, dependent: :destroy
	has_many :recurring_unavailabilities, dependent: :destroy
	has_many :provided_services, dependent: :destroy
	has_many :scans, dependent: :destroy

	before_save :default_title

	private

	def default_title
		self.title = "#{self.business_month}月のスケジュール" if self.title.blank?
	end

	def self.add_title
		plannings = Planning.where(title: nil)

		plannings.each do |planning|
			planning.title = "#{planning.business_month}月のスケジュール"
			planning.save
		end
	end
end
