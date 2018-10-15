class Unavailability < ApplicationRecord
	include PublicActivity::Common

	belongs_to :nurse, optional: true
	belongs_to :planning
	belongs_to :patient, optional: true

	before_validation :set_title
	validates :title, presence: true


	def all_day_unavailability?
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight ? true : false
	end

	private

	def set_title
		self.title = "サービス不可" if self.title.empty?
	end
end
