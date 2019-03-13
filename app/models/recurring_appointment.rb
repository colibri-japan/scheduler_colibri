class RecurringAppointment < ApplicationRecord
	include PublicActivity::Common

	attribute :editing_occurrences_after, :date
	attribute :skip_appointments_callbacks, :boolean
	attribute :request_edit_for_overlapping_appointments, :boolean
	
	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'RecurringAppointment', optional: true
	belongs_to :service, optional: true
	has_many :appointments, dependent: :destroy

	before_validation :calculate_duration
	before_validation :calculate_end_day

	before_create :default_frequency
	before_create :default_master
	before_create :default_displayable

	before_save :request_edit_if_undefined_nurse
	before_save :match_title_to_service

	before_update :update_individual_occurrences

	after_create :create_individual_appointments

	validates :anchor, presence: true
	validates :frequency, presence: true, inclusion: 0..10
	validates :title, presence: true
	validates :nurse_id, presence: true 
	validates :patient_id, presence: true
	validate :cannot_overlap_existing_appointment_create, on: :create, if: -> { nurse_id.present? }
	validate :cannot_overlap_existing_appointment_update, on: :update, if: -> { nurse_id.present? }


	skip_callback :create, :after, :create_individual_appointments, if: :skip_appointments_callbacks
	skip_callback :update, :before, :update_individual_occurrences, if: :skip_appointments_callbacks

	scope :not_archived, -> { where(archived_at: nil) }
	scope :in_range, -> range { where('(from BETWEEN ? AND ?)', range.first, range.last) }
	scope :exclude_self, -> id { where.not(id: id) }
	scope :valid, -> { where(cancelled: false, displayable: true).not_archived }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :from_master, -> { where(master: true) }
	scope :duplicatable, -> { where(duplicatable: true) }
	scope :to_be_displayed, -> { where(displayable: true).not_archived }
	scope :to_be_copied_to_new_planning, -> { where(master: true, cancelled: false, displayable: true, duplicatable: true, edit_requested: false).where.not(frequency: 2).not_archived }
	scope :not_terminated_at, -> date { where('(termination_date IS NULL) OR (termination_date > ?)', date) }

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
		start_frequency = start_date.to_date 
		end_frequency = end_date.to_date 
		end_frequency = (termination_date - 1.day) if termination_date.present? && termination_date < end_frequency
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

	def overlapping_hours(start_time, end_time)
		self_start = self.starts_at.utc.strftime("%H:%M")
		self_end = self.ends_at.utc.strftime("%H:%M")
		check_start = start_time.utc.strftime("%H:%M")
		check_end = end_time.utc.strftime("%H:%M")
		
		check_start >= self_start && check_start < self_end || check_end > self_start && check_end <= self_end || check_start <= self_start && check_end >= self_end
	end



	private

	def create_individual_appointments
		puts 'creating individual appointments'

		planning = Planning.find(self.planning_id)
		first_day = self.anchor
		last_day = self.anchor.end_of_month
		
		if self.master == true 
			puts 'master is true'
			non_master_recurring_appointment = self.dup 
			non_master_recurring_appointment.master = false 
			non_master_recurring_appointment.original_id = self.id 
			non_master_recurring_appointment.termination_date = last_day
			non_master_recurring_appointment.request_edit_for_overlapping_appointments = true
			non_master_recurring_appointment.save(validate: false)
			
		else 
			puts 'master is false'
			occurrences = self.appointments(first_day, last_day)
			
			occurrences.each do |occurrence|
				start_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.starts_at.hour, self.starts_at.min)
				end_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, self.ends_at.hour, self.ends_at.min) + self.duration.to_i
				occurrence_appointment = Appointment.new(title: self.title, nurse_id: self.nurse_id, recurring_appointment_id: self.id, patient_id: self.patient_id, planning_id: self.planning_id, master: false, displayable: true, starts_at: start_time, ends_at: end_time, color: self.color, edit_requested: self.edit_requested, description: self.description, service_id: self.service_id, request_edit_for_overlapping_appointments: self.request_edit_for_overlapping_appointments)
				occurrence_appointment.save(validate: false)
			end
		end
		

	end

	def update_individual_occurrences
		puts 'updating individual occurrences'

		if self.master == false
			appointments_to_edit = Appointment.where(recurring_appointment_id: self.id).to_be_displayed.order(starts_at: :asc)

			if self.editing_occurrences_after.present?
				puts 'inside editing occurrences'
				all_appointments = appointments_to_edit
				appointments_to_edit = appointments_to_edit.where("starts_at >= ?", self.editing_occurrences_after.to_date.beginning_of_day)
				appointments_not_to_be_edited = all_appointments - appointments_to_edit 

				recurring_appointment_before_edit = RecurringAppointment.new(title: title_was, description: description_was, nurse_id: nurse_id_was, patient_id: patient_id_was, color: color_was, master: master_was, displayable: displayable_was, cancelled: cancelled_was, planning_id: planning_id_was, anchor: anchor_was, end_day: end_day_was, starts_at: starts_at_was, ends_at: ends_at_was, skip_appointments_callbacks: true, frequency: frequency_was, original_id: id, duplicatable: false)
				recurring_appointment_before_edit.save(validate: false)

				appointments_not_to_be_edited.each do |appointment|
					appointment.recurring_appointment_id = recurring_appointment_before_edit.id
					appointment.save!(validate: false)
				end
			end

			appointments_to_edit.each do |appointment|
				start_time = DateTime.new(appointment.starts_at.year, appointment.starts_at.month, appointment.starts_at.day, self.starts_at.hour, self.starts_at.min)
				end_time = DateTime.new(appointment.ends_at.year, appointment.ends_at.month, appointment.starts_at.day, self.ends_at.hour, self.ends_at.min) + self.duration
				appointment.update(title: self.title, description: self.description, nurse_id: self.nurse_id, patient_id: self.patient_id, master: self.master, displayable: self.displayable, starts_at: start_time, ends_at: end_time, edit_requested: self.edit_requested, color: self.color, archived_at: self.archived_at, cancelled: self.cancelled, service_id: self.service_id)
			end
		else
			puts 'updating occurrences for master'
			if editing_occurrences_after.present? 
				puts 'editing occurrences after was found'
				new_recurring = self.dup 
				new_recurring.anchor = editing_occurrences_after
				new_recurring.original_id = self.id
				new_recurring.save(validate: false)
				
				self.nurse_id = self.nurse_id_was
				self.patient_id = self.patient_id_was
				self.starts_at = self.starts_at_was
				self.ends_at = self.ends_at_was
				self.color = self.color_was
				self.title = self.title_was
				self.service_id = self.service_id_was
				self.termination_date = editing_occurrences_after.to_date - 1.day
			end
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

	def cannot_overlap_existing_appointment_create
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.displayable == false
			if self.master == false
				planning = Planning.find(self.planning_id)
				first_day = self.anchor.beginning_of_month
				last_day = self.anchor.end_of_month

				self_occurrences = self.appointments(first_day, last_day)

				self_occurrences.each do |self_occurrence|
					start_of_appointment = DateTime.new(self_occurrence.year, self_occurrence.month, self_occurrence.day, self.starts_at.hour, self.starts_at.min)
					end_of_appointment = DateTime.new(self_occurrence.year, self_occurrence.month, self_occurrence.day, self.ends_at.hour, self.ends_at.min) + self.duration.to_i
					range = Range.new(start_of_appointment, end_of_appointment)

					overlaps = Appointment.where(nurse_id: self.nurse_id, planning_id: self.planning_id, displayable: true, master: self.master, edit_requested: false, archived_at: nil, cancelled: false).overlapping(range).select(:id)
					overlapping_ids = overlaps.map{|e| e.id}

					errors.add(:nurse_id, overlapping_ids) if overlapping_ids.present?
					errors[:base] << "#{start_of_appointment.strftime('%-m月%-d日')}" if overlaps.present?
				end
			elsif self.master == true 
				puts 'validates master'
				competing_recurring_appointments = RecurringAppointment.to_be_displayed.from_master.where(nurse_id: self.nurse_id).where('extract(dow FROM anchor) = ?', self.anchor.wday).where('(termination_date IS NULL) OR (termination_date > ?)', self.anchor.beginning_of_day).where.not(id: self.id)

				overlapping_ids = []
				overlapping_days = []

				competing_recurring_appointments.each do |r|
					if self.overlapping_hours(r.starts_at, r.ends_at)
						self_occurrences = self.appointments(anchor.beginning_of_day, anchor.beginning_of_day + 2.months)
						competing_occurrences = r.appointments(anchor.beginning_of_day, anchor.beginning_of_day + 2.months)
						overlapping_ids << r.id if (self_occurrences - competing_occurrences).length != self_occurrences.length 
						overlapping_days << (self_occurrences & competing_occurrences).map! {|e| e.strftime("
						%-m月%-d日")} if (self_occurrences - competing_occurrences).length != self_occurrences.length 
					end
				end
				errors.add(:nurse_id, overlapping_ids) if overlapping_ids.present? 
				errors[:base] << overlapping_days if overlapping_days.present?
			end
		end

	end

	def cannot_overlap_existing_appointment_update
		puts 'overlap validation on update'
		nurse = Nurse.find(self.nurse_id)

		if self.master == false 

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

end
