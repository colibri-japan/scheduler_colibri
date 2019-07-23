class Appointment < ApplicationRecord
	include PublicActivity::Common

	attribute :should_request_edit_for_overlapping_appointments, :boolean 
	attribute :skip_credits_invoice_and_wage_calculations, :boolean 

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'Appointment', optional: true
	belongs_to :recurring_appointment, optional: true
	belongs_to :service
	belongs_to :verifier, class_name: 'User', optional: true
	belongs_to :second_verifier, class_name: 'User', optional: true
	has_one :completion_report, dependent: :destroy
	
	before_validation :request_edit_for_overlapping_appointments, if: :should_request_edit_for_overlapping_appointments?
	before_validation :set_title_from_service_title
	
	validates :title, presence: true
	validate :do_not_overlap
	validate :nurse_patient_and_planning_from_same_corporation
	
	before_save :request_edit_if_undefined_nurse
	before_save :set_duration
	before_save :calculate_credits_invoice_and_wage, unless: :skip_credits_invoice_and_wage_calculations

	before_update :reset_verifications, unless: :verifying_appointment

	scope :not_archived, -> { where(archived_at: nil) }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :not_cancelled, -> { where(cancelled: false) }
	scope :operational, -> { not_archived.edit_not_requested.not_cancelled }
    scope :where_recurring_appointment_id_different_from, -> id { where('recurring_appointment_id IS NULL OR NOT recurring_appointment_id = ?', id) }
	scope :commented, -> { where.not(description: ['', nil]) }
	scope :in_range, -> range { where(starts_at: range) }
	scope :unverified, -> { where('verified_at IS NULL AND second_verified_at IS NULL') }

	def all_day_appointment?
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight
	end

	def verifying_appointment
		will_save_change_to_verified_at? || will_save_change_to_second_verified_at?
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

	def verified?
		verified_at.present?
	end

	def second_verified?
		second_verified_at.present? 
	end

	def toggle_second_verified!(user_id)
		if second_verified? 
			update_column(:second_verified_at, nil)
			update_column(:second_verifier_id, nil)
		else
			update_column(:second_verified_at, Time.current)
			update_column(:second_verifier_id, user_id)		
		end
	end	

	def toggle_verified!(user_id)
		if verified? 
			update_column(:verified_at, nil)
			update_column(:verifier_id, nil)
		else
			update_column(:verified_at, Time.current)
			update_column(:verifier_id, user_id)
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
			cancelled: self.cancelled,
			private_event: false,
			service_type: self.title || '',
			service_id: self.service_id,
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

	def reset_verifications
		self.verified_at = nil 
		self.verifier_id = nil 
		self.second_verified_at = nil 
		self.second_verifier_id = nil
	end
	
	def request_edit_if_undefined_nurse
		nurse = Nurse.find(self.nurse_id)
		self.edit_requested = true if nurse.name === '未定'
	end
	
	def nurse_patient_and_planning_from_same_corporation
		if self.patient.corporation_id.present? && self.nurse.corporation_id.present? && self.planning.corporation_id.present?
			corporation_id_is_matching = self.patient.corporation_id == self.planning.corporation_id && self.nurse.corporation_id == self.planning.corporation_id
			errors.add(:planning_id, "ご自身の事業所と、利用者様と従業員の事業所が異なってます。") unless corporation_id_is_matching
		end
	end

	def set_title_from_service_title
		self.title = self.service.try(:title)
	end

	def set_duration
		self.duration = self.ends_at - self.starts_at
	end

	def calculate_credits_invoice_and_wage
		if self.edit_requested? || (self.cancelled? && self.will_save_change_to_cancelled?)
			self.total_credits = 0
			self.total_invoiced = 0
			self.total_wage = 0
		elsif self.cancelled? && !self.will_save_change_to_cancelled?
		else
			self.total_credits = self.service.try(:unit_credits)
			self.total_invoiced = self.service.try(:invoiced_amount)
			if self.service.nurse_service_wages.where(nurse_id: self.nurse_id).present?
				self.total_wage = self.service.hour_based_wage? ? ((self.duration.to_f / 3600) * (self.service.nurse_service_wages.where(nurse_id: self.nurse_id).first.try(:unit_wage) || 0)) : (self.service.nurse_service_wages.where(nurse_id: self.nurse_id).first.try(:unit_wage) || 0)
			else
				self.total_wage = self.service.hour_based_wage? ? ((self.duration.to_f / 3600) * (self.service.unit_wage || 0)) : self.service.unit_wage
			end
		end
	end

	def request_edit_for_overlapping_appointments
		overlapping_appointments = Appointment.not_archived.where(nurse_id: self.nurse_id).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).where_recurring_appointment_id_different_from(self.recurring_appointment_id)
		overlapping_appointments.update_all(edit_requested: true, recurring_appointment_id: nil, updated_at: Time.current) if overlapping_appointments.present?
	end

	def do_not_overlap
		puts 'validating overlap'
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.archived? || self.edit_requested? || self.cancelled?
			overlapping_ids = Appointment.where(edit_requested: false, planning_id: self.planning_id, nurse_id: self.nurse_id, archived_at: nil, cancelled: false).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).pluck(:id)

			errors[:base] << "その日の従業員が重複しています。" if overlapping_ids.present?
			errors[:overlapping_ids] << overlapping_ids if overlapping_ids.present?
		end
	end

end
