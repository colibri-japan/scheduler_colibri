class Unavailability < ApplicationRecord
	include PublicActivity::Model
	tracked owner: Proc.new{ |controller, model| controller.current_user }
	tracked planning_id: Proc.new{ |controller, model| model.planning_id }


	belongs_to :nurse, optional: true
	belongs_to :planning
	belongs_to :patient, optional: true

	validates :title, presence: true

	def all_day_unavailability?
		self.start == self.start.midnight && self.end == self.end.mignight ? true : false
	end
end
