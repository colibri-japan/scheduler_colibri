class Appointment < ApplicationRecord
	include PublicActivity::Common
	#tracked owner: Proc.new{ |controller, model| controller.current_user }
	#tracked planning_id: Proc.new{ |controller, model| model.planning_id }

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'Appointment', optional: true
	has_many :provided_services, as: :payable

	validates :title, presence: true

	before_save :default_master
	before_save :default_displayable

	def all_day_appointment?
		self.start == self.start.midnight && self.end == self.end.mignight ? true : false
	end

	private


	def default_master
		self.master = true if self.master.nil?
	end

	def default_displayable
		self.displayable = true if self.displayable.nil?
	end

end
