class Appointment < ApplicationRecord
	include PublicActivity::Model
	tracked owner: Proc.new{ |controller, model| controller.current_user }
	tracked planning_id: Proc.new{ |controller, model| model.planning_id }

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning

	validates :title, presence: true

	def all_day_appointment?
		self.start == self.start.midnight && self.end == self.end.mignight ? true : false
	end
	
end
