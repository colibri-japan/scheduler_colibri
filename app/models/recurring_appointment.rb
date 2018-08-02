class RecurringAppointment < ApplicationRecord
	include PublicActivity::Common
	
	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'RecurringAppointment', optional: true
	has_many :provided_services, as: :payable
	has_many :deleted_occurrences

	before_save :default_frequency
	before_save :default_master
	before_save :default_displayable
	before_save :calculate_duration

	validates :anchor, presence: true
	validates :frequency, presence: true
	validates :frequency, inclusion: 0..2
	validate :cannot_overlap_existing_appointment

	#frequencies : 0 for weekly, 1 for biweekly, 2 for one timer

	def schedule
		@schedule ||= begin
			
		schedule = IceCube::Schedule.new(now = anchor)
			case frequency
			when 0
				schedule.add_recurrence_rule IceCube::Rule.weekly(1)
			when 1
				schedule.add_recurrence_rule IceCube::Rule.weekly(2)
			else
			end
			schedule
		end

	end

	def all_day_recurring_appointment?
		self.start == self.start.midnight && self.end == self.end.midnight ? true : false
	end

	def appointments(start_date, end_date)
		start_frequency = start_date ? start_date.to_date : Date.today - 1.year
		end_frequency = end_date ? end_date.to_date : Date.today + 1.year

		deleted_occurrences = self.deleted_occurrences.map { |d| d.deleted_day }
		initial_occurrences = schedule.occurrences_between(start_frequency, end_frequency)
		initial_occurrences.map! {|occurrence| occurrence.to_date }

		initial_occurrences - deleted_occurrences
	end


	private

	def self.count_as_payable
		recurring_appointments = RecurringAppointment.where(displayable: true, anchor: Time.now.beginning_of_month..Time.now.end_of_month).all



		date = Date.today
		timezone = ActiveSupport::TimeZone['Asia/Tokyo']
		start_time = timezone.local(date.year, date.month, date.day)

		end_time = start_time.end_of_day


		recurring_appointments.each do |recurring_appointment|

			occurrences = recurring_appointment.appointments(start_time, end_time)

			unless occurrences.blank?
				duration = recurring_appointment.end - recurring_appointment.start
				provided = ProvidedService.create!(payable: recurring_appointment, service_duration: duration, nurse_id: recurring_appointment.nurse_id, patient_id: recurring_appointment.patient_id, planning_id: recurring_appointment.planning_id, title: recurring_appointment.title)
			end
		end

	end

	def default_frequency
		self.frequency =0 if self.frequency.nil?
	end

	def default_master
		self.master = true if self.master.nil?
	end

	def default_displayable
		self.displayable = true if self.displayable.nil?
	end

	def calculate_duration
		if self.end_day.present? && self.anchor.present? && self.end_day != self.anchor
			self.duration = self.end_day - self.anchor
		else
			self.duration = 0
		end
	end

	def cannot_overlap_existing_appointment
		planning = Planning.find(self.planning_id)
		first_day = Date.new(planning.business_year, planning.business_month, 1)
		last_day = Date.new(planning.business_year, planning.business_month, -1)

		start_of_appointment = DateTime.new(self.anchor.year, self.anchor.month, self.anchor.day, self.start.hour, self.start.min)
		end_of_appointment = DateTime.new(self.anchor.year, self.anchor.month, self.anchor.day, self.end.hour, self.end.min)

		range = Range.new(start_of_appointment, end_of_appointment)
		overlap = []

		recurring_appointments = RecurringAppointment.where(nurse_id: self.nurse_id, planning_id: self.planning_id, displayable: true)

		recurring_appointments.each do |recurring_appointment|
			occurrences = recurring_appointment.appointments(first_day, last_day)
			occurrences.each do |appointment|
				start_time = DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.start.hour, recurring_appointment.start.min)
				end_time = DateTime.new(appointment.year, appointment.month, appointment.day, recurring_appointment.end.hour, recurring_appointment.end.min) + recurring_appointment.duration.to_i
				occurrence_range = Range.new(start_time, end_time)
				overlap << recurring_appointment if range.overlaps?(occurrence_range)
			end
		end


		#does not take into acccount full day appointments, nor multi day appointments
		errors.add(:nurse_id, "選択されたヘルパーはすでにその時間帯にサービスを提供してます。") if overlap.present?

	end

	scope :in_range, -> range { where('(from BETWEEN ? AND ?)', range.first, range.last) }
	scope :exclude_self, -> id { where.not(id: id) }
end
