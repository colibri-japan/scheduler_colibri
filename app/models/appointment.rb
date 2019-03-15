class Appointment < ApplicationRecord
	include PublicActivity::Common

	attribute :should_request_edit_for_overlapping_appointments, :boolean 

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'Appointment', optional: true
	belongs_to :recurring_appointment, optional: true
	belongs_to :service, optional: true
	has_one :provided_service, dependent: :destroy

	validates :title, presence: true
	validate :do_not_overlap
	
	before_validation :request_edit_for_overlapping_appointments, if: :should_request_edit_for_overlapping_appointments?
	before_validation :default_master, on: :create
	before_validation :default_displayable, on: :create

	before_save :request_edit_if_undefined_nurse
	before_save :match_title_to_service

	after_create :create_provided_service
	after_update :update_provided_service

	scope :not_archived, -> { where(archived_at: nil) }
	scope :valid, -> { where(cancelled: false, displayable: true).not_archived }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :from_master, -> { where(master: true) }
	scope :to_be_displayed, -> { where(displayable: true).not_archived }
	scope :to_be_copied_to_new_planning, -> { where(master: true, cancelled: false, displayable: true).not_archived }
  scope :where_recurring_appointment_id_different_from, -> id { where('recurring_appointment_id IS NULL OR NOT recurring_appointment_id = ?', id) }

	def all_day_appointment?
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight ? true : false
	end

	def weekend_holiday_appointment?
		!self.starts_at.on_weekday? || !self.ends_at.on_weekday? || HolidayJp.between(self.starts_at, self.ends_at).present? ? true : false
	end

	def should_request_edit_for_overlapping_appointments?
		should_request_edit_for_overlapping_appointments
	end

	def self.overlapping(range)
		where('((appointments.starts_at >= ? AND appointments.starts_at < ?) OR (appointments.ends_at > ? AND appointments.ends_at <= ?)) OR (appointments.starts_at < ? AND appointments.ends_at > ?)', range.first, range.last, range.first, range.last, range.first, range.last)
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

	def recurring_appointment_frequency 
		if self.recurring_appointment.present? 
			self.recurring_appointment.frequency 
		else
			''
		end
	end

	def recurring_appointment_path
		if self.recurring_appointment.present? 
			"/plannings/#{self.planning_id}/recurring_appointments/#{self.recurring_appointment_id}/edit"
		else 
			''
		end
	end

	def borderColor 
        if self.cancelled == true 
            '#FF8484'
        elsif self.edit_requested == true 
            '#99E6BF'
        end
	end

	def as_json(options = {})
		{
			id: "appointment_#{self.id}",
			title: "#{self.patient.try(:name)} - #{self.nurse.try(:name)}",
			start: self.starts_at,
			end: self.ends_at,
			patient_id: self.patient_id,
			nurse_id: self.nurse_id,
			edit_requested: self.edit_requested,
			description: self.description || '',
			resourceId: options[:patient_resource] == true ? self.patient_id : self.nurse_id,
			allDay: self.all_day_appointment?,
			color: self.color,
			displayable: self.displayable,
			master: self.master,
			cancelled: self.cancelled,
			private_event: false,
			service_type: self.title || '',
			borderColor: self.borderColor,
			nurse: {
				name: self.nurse.try(:name),
			},
			patient: {
				name: self.patient.try(:name),
				address: self.patient.try(:address)
			},
			frequency: self.recurring_appointment_frequency,
			base_url: "/plannings/#{self.planning_id}/appointments/#{self.id}",
			edit_url: "/plannings/#{self.planning_id}/appointments/#{self.id}/edit",
			recurring_appointment_path: self.recurring_appointment_path
		}
	end

	private

	def request_edit_for_overlapping_appointments
		puts 'requesting edit for overlapping appointments'
		overlapping_appointments = Appointment.to_be_displayed.where(master: false, nurse_id: self.nurse_id).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).where_recurring_appointment_id_different_from(self.recurring_appointment_id)
		overlapping_appointments.update_all(edit_requested: true, recurring_appointment_id: nil, updated_at: Time.current)
	end

	def do_not_overlap
		puts 'overlap validation on appointment'
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.displayable == false
			overlapping_ids = Appointment.where(master: self.master, displayable: true, edit_requested: false, planning_id: self.planning_id, nurse_id: self.nurse_id, archived_at: nil, cancelled: false).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).pluck(:id)

			errors.add(:nurse_id, overlapping_ids) if overlapping_ids.present? 
			errors[:base] << "その日の従業員が重複しています。" if overlapping_ids.present?
		end
	end


	def default_master
		puts 'setting default master'
		self.master ||= false
	end

	def default_displayable
		puts 'setting default displayable'
		self.displayable = true if self.displayable.nil?
	end

	def request_edit_if_undefined_nurse
		puts 'request edit if undefined nurse'
		nurse = Nurse.find(self.nurse_id)
		self.edit_requested = true if nurse.name === '未定'
	end

	def create_provided_service
		puts 'adding provided service'
		if self.master != true
		  provided_duration = self.ends_at - self.starts_at
		  is_provided =  Time.current + 9.hours > self.starts_at
		  if self.planning.corporation.equal_salary
			service_salary_id = self.service_id
		  else
			nurse_service = Service.where(title: self.title, nurse_id: self.nurse_id, corporation_id: self.planning.corporation_id).first
			if nurse_service.nil? 
				nurse_service = Service.create(title: self.title, nurse_id: self.nurse_id, corporation_id: self.planning.corporation_id)
			end
			service_salary_id = nurse_service.id
		  end
		  provided_service = ProvidedService.create!(appointment_id: self.id, planning_id: self.planning_id, service_duration: provided_duration, nurse_id: self.nurse_id, patient_id: self.patient_id, cancelled: self.cancelled, provided: is_provided, temporary: false, title: self.title, hour_based_wage: self.planning.corporation.hour_based_payroll, service_date: self.starts_at, appointment_start: self.starts_at, appointment_end: self.ends_at, service_salary_id: service_salary_id)
		end
	end

	def update_provided_service
		puts 'updating provided service'
		if self.master != true
			@provided_service = self.provided_service
			if self.archived? == true 
				@provided_service.archive!
			else
		      provided_duration = self.ends_at - self.starts_at
			  is_provided = Time.current + 9.hours > self.starts_at
			  if self.planning.corporation.equal_salary == true 
				service_salary_id = self.service_id
			  else 
				nurse_service =  Service.where(title: self.title, nurse_id: self.nurse_id, corporation_id: self.planning.corporation_id).first
				service_salary_id =  nurse_service.present? ? nurse_service.id : self.service_id
			  end
			   deactivate_provided =  self.displayable == false || self.archived? == true || self.cancelled == true
			  @provided_service.update(service_duration: provided_duration, planning_id: self.planning_id, nurse_id: self.nurse_id, patient_id: self.patient_id, title: self.title, cancelled: deactivate_provided, provided: is_provided, service_date: self.starts_at, appointment_start: self.starts_at, appointment_end: self.ends_at, service_salary_id: service_salary_id)
			end
		end
	end

	def match_title_to_service
		first_service = Service.where(title: self.title, corporation_id: self.planning.corporation.id, nurse_id: nil).first
		if first_service.present?
			self.service_id = first_service.id
		else
			new_service = self.planning.corporation.services.create(title: self.title)
			self.service_id = new_service.id
		end
	end

	def self.update_activities
		update_activities = PublicActivity::Activity.where(key: 'appointment.update', new_start: nil, new_end: nil)

		update_activities.each do |activity|
			if activity.trackable.present?
			  activity.new_start = activity.trackable.starts_at
			  activity.new_end = activity.trackable.ends_at 
			  activity.new_nurse = activity.trackable.nurse.name if activity.trackable.nurse.present? 
			  activity.new_patient = activity.trackable.patient.name  if activity.trackable.patient.present?
			  activity.new_edit_requested = activity.trackable.edit_requested

			  activity.save! 
			end
		end
	end

	def self.add_or_create_service
		appointments = Appointment.where(service_id: nil).where('starts_at > ?', Date.new(2018,10,1)) 

		appointments.find_each do |appointment|
			service = Service.where(corporation_id: appointment.planning.corporation.id, nurse_id: nil, title: appointment.title).first 
			if service.present? 
				appointment.service_id = service.id 
				appointment.save(validate: false)
			end
		end
	end
end
