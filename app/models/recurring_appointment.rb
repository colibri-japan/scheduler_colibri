class RecurringAppointment < ApplicationRecord
	include PublicActivity::Common

	attribute :editing_occurrences_after, :integer
	attribute :skip_appointments_callbacks, :boolean
	
	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'RecurringAppointment', optional: true
	belongs_to :service, optional: true
	has_many :deleted_occurrences, dependent: :destroy
	has_many :appointments, dependent: :destroy

	before_validation :calculate_duration
	before_validation :calculate_end_day

	before_create :default_frequency
	before_create :default_master
	before_create :default_displayable
	
	before_save :request_edit_if_undefined_nurse
	before_save :match_title_to_service

	validates :anchor, presence: true
	validates :frequency, presence: true
	validates :frequency, inclusion: 0..10
	validates :title, presence: true
	validate :cannot_overlap_existing_appointment_create, on: :create
	validate :cannot_overlap_existing_appointment_update, on: :update

	after_create :create_individual_appointments
	after_update :update_individual_appointments

	skip_callback :create, :after, :create_individual_appointments, if: :skip_appointments_callbacks
	skip_callback :update, :after, :update_individual_appointments, if: :skip_appointments_callbacks

	scope :not_archived, -> { where(archived_at: nil) }
	scope :in_range, -> range { where('(from BETWEEN ? AND ?)', range.first, range.last) }
	scope :exclude_self, -> id { where.not(id: id) }
	scope :valid, -> { where(cancelled: false, displayable: true).not_archived }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :from_master, -> { where(master: true) }
	scope :duplicatable, -> { where(duplicatable: true) }
	scope :to_be_displayed, -> { where(displayable: true).not_archived }
	scope :to_be_copied_to_new_planning, -> { where(master: true, cancelled: false, displayable: true, duplicatable: true, edit_requested: false).where.not(frequency: 2).not_archived }


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
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight ? true : false
	end

	def appointments(start_date, end_date)
		puts 'appointments method called'
		start_frequency = start_date ? start_date.to_date : Date.today.beginning_of_month
		end_frequency = end_date ? end_date.to_date : Date.today.end_of_month

		occurrences = schedule.occurrences_between(start_frequency, end_frequency)
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



	private

	def create_individual_appointments
		puts 'creating individual appointments'
		if self.master == false
			planning = Planning.find(self.planning_id)
			first_day = Date.new(planning.business_year, planning.business_month, 1)
			last_day = Date.new(planning.business_year, planning.business_month, -1)
			occurrences = self.appointments(first_day, last_day)


			occurrences.each do |occurrence|
				start_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.starts_at.hour, self.starts_at.min)
				end_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.ends_at.hour, self.ends_at.min) + self.duration.to_i
				occurrence_appointment = Appointment.new(title: self.title, nurse_id: self.nurse_id, recurring_appointment_id: self.id, patient_id: self.patient_id, planning_id: self.planning_id, master: self.master, displayable: true, starts_at: start_time, ends_at: end_time, color: self.color, edit_requested: self.edit_requested, description: self.description, service_id: self.service_id)
				occurrence_appointment.save!(validate: false)
			end
		end
	end

	def update_individual_appointments
		puts 'updating individual appointments'

		if self.master == false

			appointments_to_edit = Appointment.where(recurring_appointment_id: self.id, displayable: true)

			if self.editing_occurrences_after.present?

				puts 'inside editing occurrences'

				all_appointments = appointments_to_edit

				editing_start_occurrence = Appointment.find(self.editing_occurrences_after.to_i)
				edit_after_date = Date.new(editing_start_occurrence.starts_at.year, editing_start_occurrence.starts_at.month, editing_start_occurrence.starts_at.day)
				edit_after_date = edit_after_date.beginning_of_day
				appointments_to_edit = all_appointments.where("starts_at >= ?",edit_after_date)
				appointments_before_edit_date = all_appointments - appointments_to_edit 

				first_appointment = appointments_before_edit_date.first

				recurring_anchor = Date.new(first_appointment.starts_at.year, first_appointment.starts_at.month, first_appointment.starts_at.day)
				recurring_end_day = Date.new(first_appointment.ends_at.year, first_appointment.ends_at.month, first_appointment.ends_at.day)
				recurring_appointment_before_edit_date = RecurringAppointment.new(title: first_appointment.title, description: first_appointment.description, nurse_id: first_appointment.nurse_id, patient_id: first_appointment.patient_id, color: first_appointment.color, master: first_appointment.master, displayable: first_appointment.displayable, cancelled: first_appointment.cancelled, planning_id: first_appointment.planning_id, anchor: recurring_anchor, end_day: recurring_end_day, starts_at: first_appointment.starts_at, ends_at: first_appointment.ends_at, skip_appointments_callbacks: true, frequency: self.frequency, original_id: self.id, duplicatable: false)
				recurring_appointment_before_edit_date.save(validate: false)

				appointments_before_edit_date.each do |appointment|
					appointment.recurring_appointment_id = recurring_appointment_before_edit_date.id
					appointment.save!(validate: false)
				end
			end

			appointments_to_edit.each do |appointment|
				start_time = DateTime.new(appointment.starts_at.year, appointment.starts_at.month, appointment.starts_at.day, self.starts_at.hour, self.starts_at.min)
				end_time = DateTime.new(appointment.ends_at.year, appointment.ends_at.month, appointment.starts_at.day, self.ends_at.hour, self.ends_at.min) + self.duration
				appointment.update(title: self.title, description: self.description, nurse_id: self.nurse_id, patient_id: self.patient_id, master: self.master, displayable: self.displayable, starts_at: start_time, ends_at: end_time, edit_requested: self.edit_requested, color: self.color, archived_at: self.archived_at, cancelled: self.cancelled, service_id: self.service_id)
			end
		end
	end

	#def toggle_deactivated_on_individual_appointments
	#	puts 'toggle cancelled on individual appointments from recurring appointment model'
	#	appointments_to_edit = Appointment.where(recurring_appointment_id: self.id, displayable: true)
	#
	#	appointments_to_edit.each do |appointment|
	#		appointment.update_attribute(:cancelled, self.cancelled)
	#	end
	#end

	def default_frequency
		puts 'adding default frequency'
		self.frequency ||= 2
	end

	def default_master
		puts 'setting default master'
		self.master ||= false
	end

	def default_displayable
		puts 'setting default displayable'
		self.displayable = true if self.displayable.nil?
	end

	def calculate_duration
		puts 'calculating duration'
		unless self.duration.present?
			if self.end_day.present? && self.anchor.present? && self.end_day != self.anchor
				self.duration = (self.end_day - self.anchor).to_i
			else
				self.duration = 0
			end
		end
	end

	def request_edit_if_undefined_nurse
		puts 'request edit if undefined nurse'
		nurse = Nurse.find(self.nurse_id)
		self.edit_requested = true if nurse.name === '未定'
	end


	def calculate_end_day
		puts 'calculating end day'
		self.end_day = self.anchor + duration
	end

	def cannot_overlap_existing_appointment_create
		puts 'overlap validation on create'
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.displayable == false
			if master == false
				planning = Planning.find(self.planning_id)
				first_day = Date.new(planning.business_year, planning.business_month, 1)
				last_day = Date.new(planning.business_year, planning.business_month, -1)

				self_occurrences = self.appointments(first_day, last_day)
				master = self.master.present? ? self.master : true

				self_occurrences.each do |self_occurrence|
					start_of_appointment = DateTime.new(self_occurrence.year, self_occurrence.month, self_occurrence.day, self.starts_at.hour, self.starts_at.min)
					end_of_appointment = DateTime.new(self_occurrence.year, self_occurrence.month, self_occurrence.day, self.ends_at.hour, self.ends_at.min) + self.duration.to_i
					range = Range.new(start_of_appointment, end_of_appointment)

					overlaps = Appointment.where(nurse_id: self.nurse_id, planning_id: self.planning_id, displayable: true, master: self.master, edit_requested: false, archived_at: nil, cancelled: false).overlapping(range).select(:id)
					overlapping_ids = overlaps.map{|e| e.id}

					errors.add(:nurse_id, overlapping_ids) if overlapping_ids.present?
					errors[:base] << "#{start_of_appointment.strftime('%-m月%-d日')}" if overlaps.present?
				end
			end
		end

	end

	def cannot_overlap_existing_appointment_update
		puts 'overlap validation on update'
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.displayable == false
			appointments_to_be_validated = Appointment.where(recurring_appointment_id: self.id, displayable: true, master: self.master)


			appointments_to_be_validated.each do |appointment_to_be_validated|
				start_time = DateTime.new(appointment_to_be_validated.starts_at.year, appointment_to_be_validated.starts_at.month, appointment_to_be_validated.starts_at.day, self.starts_at.hour, self.starts_at.min)
				end_time = DateTime.new(appointment_to_be_validated.ends_at.year, appointment_to_be_validated.ends_at.month, appointment_to_be_validated.ends_at.day, self.ends_at.hour, self.ends_at.min)
				range = Range.new(start_time, end_time)
				overlaps = Appointment.where(nurse_id: self.nurse_id, planning_id: self.planning_id, displayable: true, master: self.master, edit_requested: false, archived_at: nil, cancelled: false).where.not(recurring_appointment_id: self.id).where.not(id: [appointment_to_be_validated.original_id, appointment_to_be_validated.id]).overlapping(range).select(:id)
				
				overlapping_ids = overlaps.map{|e| e.id} 
				
				errors.add(:nurse_id, overlapping_ids) if overlapping_ids.present?
				errors[:base] << "#{start_time.strftime('%-m月%-d日')}" if overlaps.present?
			end

		end
	end

	def self.create_appointments 
		@recurring_appointments = RecurringAppointment.where(displayable: true)

		@recurring_appointments.each do |recurring_appointment|
			planning = Planning.find(recurring_appointment.planning_id)
			first_day = Date.new(planning.business_year, planning.business_month, 1)
			last_day = Date.new(planning.business_year, planning.business_month, -1)
			occurrences = recurring_appointment.appointments(first_day, last_day)

			occurrences.each do |occurrence|
				start_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
			    end_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i
				occurrence_appointment = Appointment.new(title: recurring_appointment.title, nurse_id: recurring_appointment.nurse_id, recurring_appointment_id: recurring_appointment.id, patient_id: recurring_appointment.patient_id, planning_id: recurring_appointment.planning_id, master: recurring_appointment.master, displayable: true, starts_at: start_time, ends_at: end_time, color: recurring_appointment.color, edit_requested: recurring_appointment.edit_requested)
				occurrence_appointment.save!(validate: false)
			end
		end
	end

	def self.mark_recurring_appointments_as_deleted
		recurring_appointments_to_be_deleted = RecurringAppointment.where(displayable: false)

		recurring_appointments_to_be_deleted.each do |recurring_appointment_to_be_deleted|
			recurring_appointment_to_be_deleted.archived_at = Time.current
			recurring_appointment_to_be_deleted.save!(validate: false)
		end
	end

	def match_title_to_service
		puts 'match title to services'
		first_service = Service.where(corporation_id: self.planning.corporation.id, title: self.title, nurse_id: nil).first
		
		if first_service.present? 
			self.service_id = first_service.id
		else
			new_service = self.planning.corporation.services.create(title: self.title)
			self.service_id = new_service.id
		end
	end

	def self.create_activities
		create_activities = PublicActivity::Activity.where(key: 'recurring_appointment.create', new_anchor: nil, new_start: nil)

		create_activities.each do |activity|
			if activity.trackable.present?
				activity.new_anchor = activity.trackable.anchor
				activity.new_start = activity.trackable.starts_at
				activity.new_end = activity.trackable.ends_at 
				activity.new_nurse = activity.trackable.nurse.name if activity.trackable.nurse.present?
				activity.new_patient = activity.trackable.patient.name if activity.trackable.patient.present?
				activity.new_edit_requested = activity.trackable.edit_requested
				activity.save! 
			end
		end
	end

	def self.update_activities 
		update_activities = PublicActivity::Activity.where(key: 'recurring_appointment.update', new_start: nil)

		update_activities.each do |activity|
			if activity.trackable.present?
				activity.new_anchor = activity.trackable.anchor
				activity.new_start = activity.trackable.starts_at
				activity.new_end = activity.trackable.ends_at 
				activity.new_nurse = activity.trackable.nurse.name if activity.trackable.nurse.present?
				activity.new_patient = activity.trackable.patient.name if activity.trackable.patient.present?
				activity.new_edit_requested = activity.trackable.edit_requested
				activity.save! 
			end
		end
	end

	def self.archive_activities
		archive_activities = PublicActivity::Activity.where(key: 'recurring_appointment.archive', previous_start: nil)

		archive_activities.each do |activity|
			if activity.trackable.present?
				activity.previous_anchor = activity.trackable.anchor
				activity.previous_start = activity.trackable.starts_at
				activity.previous_end = activity.trackable.ends_at 
				activity.previous_nurse = activity.trackable.nurse.name if activity.trackable.nurse.present?
				activity.previous_patient = activity.trackable.patient.name if activity.trackable.patient.present?

				activity.save! 
			end
		end
	end

	def self.add_or_create_service
		appointments = RecurringAppointment.where(service_id: nil) 

		appointments.find_each do |appointment|
			service = Service.where(corporation_id: appointment.planning.corporation.id, nurse_id: nil, title: appointment.title).first
			if service.present?
				appointment.service_id = service.id
				appointment.skip_appointments_callbacks = true
				appointment.save(validate: false)
			end
		end
	end


end
