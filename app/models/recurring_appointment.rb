class RecurringAppointment < ApplicationRecord
	include PublicActivity::Common

	attribute :editing_occurrences_after, :date
	attribute :request_edit_for_overlapping_appointments, :boolean
	attribute :synchronize_appointments, :boolean
	
	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'RecurringAppointment', optional: true
	belongs_to :service, optional: true
	has_many :appointments, dependent: :destroy

	before_validation :calculate_duration
	before_validation :calculate_end_day
	
	validates :anchor, presence: true
	validates :frequency, presence: true, inclusion: 0..10
	validates :title, presence: true
	validates :nurse_id, presence: true 
	validates :patient_id, presence: true
	validate :nurse_patient_and_planning_from_same_corporation
	validate :cannot_overlap_existing_appointment_create, on: :create

	before_create :default_frequency
	before_create :default_master
	before_create :default_displayable

	before_save :request_edit_if_undefined_nurse
	before_save :match_title_to_service

	before_update :split_recurring_appointment_before_after_update
	after_commit :update_appointments, on: :update

	scope :not_archived, -> { where(archived_at: nil) }
	scope :exclude_self, -> id { where.not(id: id) }
	scope :valid, -> { where(cancelled: false, displayable: true).not_archived }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :from_master, -> { where(master: true) }
	scope :duplicatable, -> { where(duplicatable: true) }
	scope :to_be_displayed, -> { where(displayable: true).not_archived }
	scope :to_be_copied_to_new_planning, -> { where(master: true, cancelled: false, displayable: true, duplicatable: true, edit_requested: false).where.not(frequency: 2).not_archived }
	scope :not_terminated_at, -> date { where('(termination_date IS NULL) OR (termination_date > ?)', date) }
	scope :occurs_in_range, -> range { select {|r| r.occurs_between?(range.first, range.last) } }

	def schedule
		@schedule ||= begin

		day_of_week = anchor.wday
		end_of_month = Date.new(anchor.year, anchor.month, -1) 
			
		schedule = IceCube::Schedule.new(now = anchor)
			case frequency
			when 0
				# weekly
				schedule.add_recurrence_rule IceCube::Rule.weekly(1)
			when 1
				# bi weekly starting first week
				schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week => [1,3,5])
			when 2
				#only that day == no rule
			when 3
				# bi weekly starting second week
				schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week => [2,4])
			when 4
				#only the first week
				schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[1])
			when 5
				#only the last week
				schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week => [-1])
			when 6
				#every week except the last one
				schedule.add_recurrence_rule IceCube::Rule.weekly(1)
				exception_time = end_of_month - (end_of_month.wday - day_of_week) % 7
				schedule.add_exception_time(exception_time)
			when 7
				#every other week
				schedule.add_recurrence_rule IceCube::Rule.weekly(2)
			when 8 
				#only the second week
				schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[2])
			when 9 
				#only the third week
				schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[3])
			when 10 
				#only the forth week
				schedule.add_recurrence_rule IceCube::Rule.monthly(1).day_of_week(day_of_week =>[4])
			else
			end
			schedule
		end

	end

	def all_day_recurring_appointment?
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight
	end

	def synchronize_appointments?
		synchronize_appointments
	end

	def border_color 
		'#FFBBA0' if edit_requested
	end

	def appointments(start_date, end_date)
		end_date = (termination_date - 1.day) if termination_date.present? && termination_date < end_date.to_date
		schedule.occurrences_between(start_date.to_date, end_date.to_date)
	end

	def occurs_between?(start_date, end_date)
		schedule.occurs_between?(start_date.to_date, end_date.to_date)
	end

	def archived?
		self.archived_at.present?
	end

	def archive 
		self.archived_at = Time.current 
	end

	def archive! 
		self.update_column(:archived_at, Time.current)
	end

	def self.overlapping_hours(start_time, end_time)
		check_start = start_time.utc.strftime("%H:%M")
		check_end = end_time.utc.strftime("%H:%M")
		
		select { |r| check_start >= r.starts_at.utc.strftime("%H:%M") && check_start < r.ends_at.utc.strftime("%H:%M") || check_end > r.starts_at.utc.strftime("%H:%M") && check_end <= r.ends_at.utc.strftime("%H:%M") || check_start <= r.starts_at.utc.strftime("%H:%M") && check_end >= r.ends_at.utc.strftime("%H:%M") }
	end

	def overlapping_hours(start_time, end_time)
		self_start = self.starts_at.utc.strftime("%H:%M")
		self_end = self.ends_at.utc.strftime("%H:%M")
		check_start = start_time.utc.strftime("%H:%M")
		check_end = end_time.utc.strftime("%H:%M")
		
		check_start >= self_start && check_start < self_end || check_end > self_start && check_end <= self_end || check_start <= self_start && check_end >= self_end
	end

	def as_json(options = {})
		date_format = self.all_day_recurring_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

		returned_json_array = []
		self.appointments(options[:start_time], options[:end_time]).each do |occurrence|
			returned_json_array << {
				allDay: self.all_day_recurring_appointment?,
				id: "recurring_#{self.id}",
				color: self.color,
				displayable: self.displayable,
				master: master,
				frequency: self.frequency,
				edit_requested: self.edit_requested,
				description: self.description || '',
				patient_id: self.patient_id,
				nurse_id: self.nurse_id,
				cancelled: self.cancelled,
				termination_date: self.termination_date,
				title: "#{self.patient.try(:name)} - #{self.nurse.try(:name)}",
				start: DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.starts_at.hour, self.starts_at.min).try(:strftime, date_format),
				end: (DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.ends_at.hour, self.ends_at.min) + self.duration.to_i).try(:strftime, date_format),
				resourceId: options[:patient_resource] == true ? self.patient_id : self.nurse_id,
				borderColor: self.border_color,
				private_event: false,
				service_type: self.title,
				patient: {
					name: self.patient.try(:name),
					address: self.patient.try(:address)
				},
				nurse: {
					name: self.nurse.try(:name)
				},
				eventType: 'recurring_appointment',
				base_url: "/plannings/#{self.planning_id}/recurring_appointments/#{self.id}",
				edit_url: "/plannings/#{self.planning_id}/recurring_appointments/#{self.id}/edit"
			}
		end

		returned_json_array
	end

	private

	def split_recurring_appointment_before_after_update
		if self.master == true && editing_occurrences_after.present? 
			new_recurring = self.dup 
			new_recurring.original_id = self.id

			if new_recurring.save 
				puts 'new recurring has been saved with id:'
				puts new_recurring.id
				Appointment.not_archived.where('starts_at >= ?', editing_occurrences_after).where(recurring_appointment_id: self.id).update_all(updated_at: Time.current, recurring_appointment_id: new_recurring.id)
				synchronize_appointments = self.synchronize_appointments
				editing_occurrences_after_date = self.editing_occurrences_after.to_date
				self.restore_attributes
				self.updated_at = Time.current
				self.editing_occurrences_after = editing_occurrences_after_date
				self.synchronize_appointments = synchronize_appointments
				self.termination_date = editing_occurrences_after_date - 1.day
			else
				self.errors[:base] << new_recurring.errors[:base]
				raise ActiveRecord::Rollback
			end
		end
	end

	def update_appointments 
		if synchronize_appointments && editing_occurrences_after.blank?
			UpdateIndividualAppointmentsWorker.perform_async(self.id)
		elsif synchronize_appointments && editing_occurrences_after.present? 
			new_recurring_id = RecurringAppointment.where(original_id: self.id).last.id
			puts 'found new recurring'
			puts new_recurring_id
			UpdateIndividualAppointmentsWorker.perform_async(new_recurring_id)
		end
	end

	def default_frequency
		self.frequency ||= 2
	end

	def default_master
		self.master ||= false
	end

	def default_displayable
		self.displayable = true if self.displayable.nil?
	end

	def calculate_duration
		unless self.duration.present?
			if self.end_day.present? && self.anchor.present? && self.end_day != self.anchor
				self.duration = (self.end_day - self.anchor).to_i
			else
				self.duration = 0
			end
		end
	end

	def request_edit_if_undefined_nurse
		nurse = Nurse.find(self.nurse_id)
		self.edit_requested = true if nurse.name === '未定'
	end


	def calculate_end_day
		self.end_day = self.anchor + duration
	end

	def nurse_patient_and_planning_from_same_corporation
		if self.patient.corporation_id.present? && self.nurse.corporation_id.present? && self.planning.corporation_id.present?
			corporation_id_is_matching = self.patient.corporation_id == self.planning.corporation_id && self.nurse.corporation_id == self.planning.corporation_id
			errors.add(:planning_id, "ご自身の事業所と、利用者様と従業員の事業所が異なってます。") unless corporation_id_is_matching
		end
	end

	def cannot_overlap_existing_appointment_create
		nurse = Nurse.find(self.nurse_id) rescue nil

		if nurse.present? && self.master
			competing_recurring_appointments = RecurringAppointment.to_be_displayed.from_master.where(nurse_id: self.nurse_id).where('extract(dow FROM anchor) = ?', self.anchor.wday).not_terminated_at(self.anchor.beginning_of_day).where.not(id: [self.id, self.original_id]).overlapping_hours(self.starts_at, self.ends_at)

			overlapping_ids = []
			overlapping_days = []

			self_occurrences = self.appointments(anchor.beginning_of_day, anchor.beginning_of_day + 2.months)
			competing_recurring_appointments.each do |r|
				competing_occurrences = r.appointments(anchor.beginning_of_day, anchor.beginning_of_day + 2.months)
				is_overlapping = (self_occurrences - competing_occurrences).length != self_occurrences.length 
				overlapping_ids << r.id if is_overlapping 
				overlapping_days << (self_occurrences & competing_occurrences).map! {|e| e.strftime("%-m月%-d日")} if is_overlapping
			end
			errors.add(:nurse_id, overlapping_ids) if overlapping_ids.present? 
			errors[:base] << overlapping_days if overlapping_days.present?
		end

	end


	def match_title_to_service
		first_service = Service.where(corporation_id: self.planning.corporation.id, title: self.title, nurse_id: nil).first
		
		if first_service.present? 
			self.service_id = first_service.id
		else
			new_service = self.planning.corporation.services.create(title: self.title)
			self.service_id = new_service.id
		end
	end


end
