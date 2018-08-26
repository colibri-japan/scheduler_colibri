class Appointment < ApplicationRecord
	include PublicActivity::Common

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'Appointment', optional: true
	belongs_to :recurring_appointment, optional: true
	has_many :provided_services, as: :payable

	validates :title, presence: true

	before_save :default_master
	before_save :default_displayable

	def all_day_appointment?
		self.start == self.start.midnight && self.end == self.end.mignight ? true : false
	end

	private

	def self.count_as_payable
		date = Date.today
		timezone = ActiveSupport::TimeZone['Asia/Tokyo']
		start_time = timezone.local(date.year, date.month, date.day)
		end_time = start_time.end_of_day

		appointments = Appointment.where(master: false, displayable: true, end: start_time..end_time, edit_requested: false)

		appointments.each do |appointment|
			duration = appointment.end - appointment.start
			provided = ProvidedService.create!(payable: appointment, service_duration: duration, nurse_id: appointment.nurse_id, patient_id: appointment.patient_id, planning_id: appointment.planning_id, title: appointment.title)
		end

	end


	def default_master
		self.master = true if self.master.nil?
	end

	def default_displayable
		self.displayable = true if self.displayable.nil?
	end

end
