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
	has_one :completion_report, dependent: :destroy
	
	before_validation :request_edit_for_overlapping_appointments, if: :should_request_edit_for_overlapping_appointments?
	before_validation :default_master, on: :create
	before_validation :default_displayable, on: :create
	
	validates :title, presence: true
	validate :do_not_overlap
	validate :nurse_patient_and_planning_from_same_corporation
	
	before_save :request_edit_if_undefined_nurse
	before_save :match_title_to_service

	after_create :create_provided_service
	after_update :update_provided_service

	before_destroy :record_delete_activity

	scope :not_archived, -> { where(archived_at: nil) }
	scope :valid, -> { where(cancelled: false, displayable: true).not_archived }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :from_master, -> { where(master: true) }
	scope :to_be_displayed, -> { where(displayable: true).not_archived }
	scope :to_be_copied_to_new_planning, -> { where(master: true, cancelled: false, displayable: true).not_archived }
    scope :where_recurring_appointment_id_different_from, -> id { where('recurring_appointment_id IS NULL OR NOT recurring_appointment_id = ?', id) }

	def all_day_appointment?
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight
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
		date_format = self.all_day_appointment? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'
		{
			id: "appointment_#{self.id}",
			title: "#{self.patient.try(:name)} - #{self.nurse.try(:name)}",
			start: self.starts_at.try(:strftime, date_format),
			end: self.ends_at.try(:strftime, date_format),
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
			eventType: 'appointment',
			frequency: self.recurring_appointment_frequency,
			base_url: "/plannings/#{self.planning_id}/appointments/#{self.id}",
			edit_url: "/plannings/#{self.planning_id}/appointments/#{self.id}/edit",
			recurring_appointment_path: self.recurring_appointment_path
		}
	end

	private

	def request_edit_for_overlapping_appointments
		overlapping_appointments = Appointment.to_be_displayed.where(master: false, nurse_id: self.nurse_id).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).where_recurring_appointment_id_different_from(self.recurring_appointment_id)
		overlapping_appointments.update_all(edit_requested: true, recurring_appointment_id: nil, updated_at: Time.current) if overlapping_appointments.present?
	end

	def nurse_patient_and_planning_from_same_corporation
		if self.patient.corporation_id.present? && self.nurse.corporation_id.present? && self.planning.corporation_id.present?
			corporation_id_is_matching = self.patient.corporation_id == self.planning.corporation_id && self.nurse.corporation_id == self.planning.corporation_id
			errors.add(:planning_id, "ご自身の事業所と、利用者様と従業員の事業所が異なってます。") unless corporation_id_is_matching
		end
	end

	def do_not_overlap
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.displayable == false
			overlapping_ids = Appointment.where(master: self.master, displayable: true, edit_requested: false, planning_id: self.planning_id, nurse_id: self.nurse_id, archived_at: nil, cancelled: false).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).pluck(:id)

			errors.add(:nurse_id, overlapping_ids) if overlapping_ids.present? 
			errors[:base] << "その日の従業員が重複しています。" if overlapping_ids.present?
		end
	end

	def default_master
		self.master ||= false
	end

	def default_displayable
		self.displayable = true if self.displayable.nil?
	end

	def request_edit_if_undefined_nurse
		nurse = Nurse.find(self.nurse_id)
		self.edit_requested = true if nurse.name === '未定'
	end

	def create_provided_service
		if !self.master
		  provided_duration = self.ends_at - self.starts_at
			nurse_service = Service.where(title: self.title, nurse_id: self.nurse_id, corporation_id: self.planning.corporation_id).first 
			service_salary_id = nurse_service.present? ? nurse_service.id : self.service_id
		  provided_service = ProvidedService.create(appointment_id: self.id, planning_id: self.planning_id, service_duration: provided_duration, nurse_id: self.nurse_id, patient_id: self.patient_id, cancelled: self.cancelled, temporary: false, title: self.title, service_date: self.starts_at, appointment_start: self.starts_at, appointment_end: self.ends_at, service_salary_id: service_salary_id)
		end
	end

	def update_provided_service
		provided_service = self.provided_service

		if provided_service.present?
			provided_duration = self.ends_at - self.starts_at
			nurse_service_id = Service.where(title: self.title, nurse_id: self.nurse_id, corporation_id: self.planning.corporation_id).first.try(:id)
			service_salary_id = nurse_service_id || self.service_id

			provided_service.update(service_duration: provided_duration, planning_id: self.planning_id, nurse_id: self.nurse_id, patient_id: self.patient_id, title: self.title, cancelled: self.cancelled, archived_at: self.archived_at, service_date: self.starts_at, appointment_start: self.starts_at, appointment_end: self.ends_at, service_salary_id: service_salary_id)
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

	def record_delete_activity
		self.create_activity :destroy, previous_patient: self.patient.try(:name), previous_nurse: self.nurse.try(:name), previous_start: self.starts_at, previous_end: self.ends_at, nurse_id: self.nurse_id, patient_id: self.patient_id
	end

end
