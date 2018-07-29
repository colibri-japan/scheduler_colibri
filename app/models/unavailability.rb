class Unavailability < ApplicationRecord
	include PublicActivity::Model
	tracked owner: Proc.new{ |controller, model| controller.current_user }
	tracked planning_id: Proc.new{ |controller, model| model.planning_id }


	belongs_to :nurse, optional: true
	belongs_to :planning
	belongs_to :patient, optional: true

	before_validation :set_title
	validates :title, presence: true


	def all_day_unavailability?
		self.start == self.start.midnight && self.end == self.end.midnight ? true : false
	end

	private

	def set_title
		self.title = "サービス不可" if self.title.empty?
	end
end
