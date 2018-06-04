class Appointment < ApplicationRecord

	belongs_to :nurse, optional: true

	validates :title, presence: true

	def all_day_appointment?
		self.start == self.start.midnight && self.end == self.end.mignight ? true : false
	end
	
end
