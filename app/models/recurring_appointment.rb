class RecurringAppointment < ApplicationRecord
	include PublicActivity::Common

	attribute :edited_occurrence, :date
	attribute :skip_appointments_callbacks, :boolean
	
	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'RecurringAppointment', optional: true
	has_many :provided_services, as: :payable, dependent: :destroy
	has_many :deleted_occurrences, dependent: :destroy
	has_many :appointments, dependent: :destroy

	before_validation :calculate_duration
	before_validation :default_frequency
	before_save :default_master
	before_save :default_displayable

	validates :anchor, presence: true
	validates :frequency, presence: true
	validates :frequency, inclusion: 0..2
	validate :cannot_overlap_existing_appointment

	after_create :create_individual_appointments
	after_update :update_individual_appointments

	skip_callback :create, :after, :create_individual_appointments, if: :skip_appointments_callbacks
	skip_callback :update, :after, :update_individual_appointments, if: :skip_appointments_callbacks


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

	def self.add_default_color
		recurring_appointments = RecurringAppointment.where(color: ['', nil])

		recurring_appointments.each do |recurring_appointment|
			recurring_appointment.update(color: '#7AD5DE')
		end
	end


	private

	def create_individual_appointments
		planning = Planning.find(self.planning_id)
		first_day = Date.new(planning.business_year, planning.business_month, 1)
		last_day = Date.new(planning.business_year, planning.business_month, -1)
		occurrences = self.appointments(first_day, last_day)


		occurrences.each do |occurrence|
			start_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.start.hour, self.start.min)
		    end_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.end.hour, self.end.min) + self.duration.to_i
			appointment = Appointment.create(title: self.title, nurse_id: self.nurse_id, recurring_appointment_id: self.id, patient_id: self.patient_id, planning_id: self.planning_id, master: self.master, displayable: true, start: start_time, end: end_time, color: self.color, edit_requested: self.edit_requested)
		end
	end

	def update_individual_appointments
		appointments = Appointment.where(recurring_appointment_id: self.id, displayable: true)
		original_recurring_appointment = RecurringAppointment.where(id: self.original_id) if self.original_id.present?

		appointments.each do |appointment|
			start_time = DateTime.new(appointment.start.year, appointment.start.month, appointment.start.day, self.start.hour, self.start.min)
			end_time = DateTime.new(appointment.end.year, appointment.end.month, appointment.end.day, self.end.hour, self.end.min)
			appointment.update(title: self.title, nurse_id: self.nurse_id, patient_id: self.patient_id, master: self.master, displayable: self.displayable, start: start_time, end: end_time, edit_requested: self.edit_requested)
		end

	end

	def default_frequency
		self.frequency =2 if self.frequency.nil?
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
		puts 'validation called'
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.displayable == false
			puts 'within validation'
			planning = Planning.find(self.planning_id)
			first_day = Date.new(planning.business_year, planning.business_month, 1)
			last_day = Date.new(planning.business_year, planning.business_month, -1)

			self_occurrences = self.appointments(first_day, last_day)
			master = self.master.present? ? self.master : true

			puts 'self occurrences'
			puts self_occurrences

			self_occurrences.each do |self_occurrence|
				start_of_appointment = DateTime.new(self_occurrence.year, self_occurrence.month, self_occurrence.day, self.start.hour, self.start.min)
				end_of_appointment = DateTime.new(self_occurrence.year, self_occurrence.month, self_occurrence.day, self.end.hour, self.end.min) + self.duration.to_i
				range = Range.new(start_of_appointment, end_of_appointment)

				puts 'range of this occurrence'
				puts range
				puts  'range in  query'
				puts start_of_appointment..end_of_appointment

				overlaps = Appointment.where(nurse_id: self.nurse_id, planning_id: self.planning_id, displayable: true, master: self.master, edit_requested: false, start: start_of_appointment..end_of_appointment, end: start_of_appointment..end_of_appointment)
				puts 'overlaps'
				puts overlaps
				errors.add(:nurse_id, "#{start_of_appointment.strftime('%-m月%-d日')}にサービスがすでに提供されます。") if overlaps.present?
			end
		end

	end

	scope :in_range, -> range { where('(from BETWEEN ? AND ?)', range.first, range.last) }
	scope :exclude_self, -> id { where.not(id: id) }
end
