class Appointment < ApplicationRecord
	include PublicActivity::Common
	include CalendarEvent
	include Archivable

	attribute :should_request_edit_for_overlapping_appointments, :boolean 
	attribute :skip_credits_invoice_and_wage_calculations, :boolean 
	attribute :remove_second_nurse, :boolean

	belongs_to :nurse, optional: true
	belongs_to :second_nurse, class_name: 'Nurse', optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original_recurring_appointment, class_name: 'RecurringAppointment', optional: true
	belongs_to :recurring_appointment, optional: true
	belongs_to :service
	belongs_to :verifier, class_name: 'User', optional: true
	belongs_to :second_verifier, class_name: 'User', optional: true
	has_one :completion_report, as: :reportable, dependent: :destroy
	
	before_validation :request_edit_for_overlapping_appointments, if: :should_request_edit_for_overlapping_appointments?
	before_validation :set_title_from_service_title
	before_validation :remove_second_nurse_if_same_as_nurse
	before_validation :remove_second_nurse_if_requested
	
	validates :title, presence: true
	validate :do_not_overlap
	
	before_save :request_edit_if_undefined_nurse
	before_save :set_duration
	before_save :calculate_credits_invoice_and_wage, unless: :skip_credits_invoice_and_wage_calculations

	before_update :reset_verifications, unless: :verifying_appointment

	scope :not_archived, -> { where(archived_at: nil) }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :edit_requested, -> { where(edit_requested: true) }
	scope :not_cancelled, -> { where(cancelled: false) }
	scope :cancelled, -> { where(cancelled: true) }
	scope :operational, -> { not_archived.edit_not_requested.not_cancelled }
    scope :where_recurring_appointment_id_different_from, -> id { where('recurring_appointment_id IS NULL OR NOT recurring_appointment_id = ?', id) }
	scope :commented, -> { where.not(description: ['', nil]) }
	scope :in_range, -> range { where(starts_at: range) }
	scope :unverified, -> { where('verified_at IS NULL AND second_verified_at IS NULL') }
	scope :with_nurse_or_second_nurse_by_id, -> nurse_id { where('(appointments.nurse_id IN (?)) OR (appointments.second_nurse_id IN (?))', nurse_id, nurse_id) }

	def with_nurse_id?(id)
		nurse_id == id 
	end

	def with_second_nurse_id?(id)
		second_nurse_id == id 
	end

	def verifying_appointment
		will_save_change_to_verified_at? || will_save_change_to_second_verified_at?
	end

	def should_request_edit_for_overlapping_appointments?
		should_request_edit_for_overlapping_appointments
	end

	def self.overlapping(range)
		where('((appointments.starts_at >= ? AND appointments.starts_at < ?) OR (appointments.ends_at > ? AND appointments.ends_at <= ?)) OR (appointments.starts_at < ? AND appointments.ends_at > ?)', range.first, range.last, range.first, range.last, range.first, range.last)
	end

	def self.calculate_wage_for_nurse_with_id(nurse_id)
		total_wage = 0 

		wage_as_main_nurse = self.where(nurse_id: nurse_id).sum(:total_wage) || 0
		wage_as_second_nurse = self.where(second_nurse_id: nurse_id).sum(:second_nurse_wage) || 0

		total_wage = wage_as_main_nurse + wage_as_second_nurse
	end

	def self.get_overlapping_instances
		overlapping_instances = []

		Appointment.where(id: self.ids).order(:starts_at).to_a.group_by {|a| a.nurse_id}.each do |nurse_id, appointments|
			if appointments.size > 1
				for i in 0..appointments.size - 2
					if appointments[i + 1].starts_at < appointments[i].ends_at  
						overlapping_instances.push(appointments[i], appointments[i + 1])
					end
				end
			end
		end

		overlapping_instances.uniq
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

	def previous_report_comment
		Appointment.operational.where(patient_id: patient_id).in_range((starts_at - 4.weeks)..(starts_at - 1.minute)).order('starts_at DESC').first.try(:completion_report).try(:general_comment)
	end

	def borderColor 
        if self.cancelled == true 
            '#FF8484'
        elsif self.edit_requested == true 
			'#99E6BF'
		else
			self.color
        end
	end

	def resource_ids_for_calendar
		if second_nurse_id.present?
			["patient_#{patient_id}", "nurse_#{nurse_id}", "nurse_#{second_nurse_id}"]
		else
			["patient_#{patient_id}", "nurse_#{nurse_id}"]
		end
	end

	def as_json(options = {})
		date_format = self.all_day? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M'

		{
			id: "appointment_#{self.id}",
			title: "#{self.patient.try(:name)} - #{self.nurse.try(:name)}",
			start: self.starts_at.try(:strftime, date_format),
			end: self.ends_at.try(:strftime, date_format),
			patient_id: self.patient_id,
			nurse_id: self.nurse_id,
			edit_requested: self.edit_requested,
			description: self.description || '',
			resourceIds: self.resource_ids_for_calendar,
			allDay: self.all_day?,
			backgroundColor: self.color,
			borderColor: self.borderColor,
			cancelled: self.cancelled,
			serviceType: self.title || '',
			service_id: self.service_id,
			nurse: {
				name: self.nurse.try(:name),
			},
			second_nurse: {
				name: self.second_nurse.try(:name),
			},
			patient: {
				name: self.patient.try(:name),
				address: self.patient.try(:address)
			},
			eventType: 'appointment',
			eventId: self.id,
			previous_report_comment: options[:list_view] == true ? self.previous_report_comment : ''
		}
	end


	def self.grouped_by_weighted_category(options = {})
		return_hash = {}
		categories = (options[:categories].blank? || options[:categories] == ['null']) ? Array(0..9) : options[:categories].map(&:to_i)
		categories.map {|category| return_hash[category] = {sum_weighted_service_duration: 0, sum_weighted_credits: 0, weighted_service_duration_percentage: 0, sum_weighted_total_wage: 0, sum_count: 0} }

		if self.present?
			data_grouped_by_title = self.includes(:service).group(:service_id).select('appointments.service_id, sum(appointments.duration) as sum_service_duration, sum(appointments.total_wage) as sum_total_wage, sum(appointments.total_credits) as sum_total_credits, count(*)')

			data_grouped_by_title.each do |grouped_appointment|
				service = grouped_appointment.service

				if service.present?
					argument = service.category_ratio.present? ? service.category_ratio : 1
					if service.category_1.present? && categories.include?(service.category_1)
						return_hash[service.category_1][:sum_weighted_credits] += (grouped_appointment.sum_total_credits || 0) * argument || 0
						return_hash[service.category_1][:sum_weighted_service_duration] += (grouped_appointment.sum_service_duration || 0) * argument || 0
						return_hash[service.category_1][:sum_weighted_total_wage] += (grouped_appointment.sum_total_wage || 0) * argument || 0
						return_hash[service.category_1][:sum_count] += grouped_appointment.count || 0
					end
					if service.category_2.present? && categories.include?(service.category_2)
						return_hash[service.category_2][:sum_weighted_credits] += (grouped_appointment.sum_total_credits || 0) * (1 - argument) || 0
						return_hash[service.category_2][:sum_weighted_service_duration] += (grouped_appointment.sum_service_duration || 0) * (1 - argument) || 0
						return_hash[service.category_2][:sum_weighted_total_wage] += (grouped_appointment.sum_total_wage || 0) * (1 - argument) || 0
						return_hash[service.category_2][:sum_count] += grouped_appointment.count || 0
					end 
				end
			end
			
			return_hash.each do |key, value|
				return_hash.delete(key) if return_hash[key].map {|k,v| v}.sum == 0
			end

			total_service_duration = return_hash.sum {|k,v| v[:sum_weighted_service_duration]}

			return_hash.each do |key, value|
				value[:weighted_service_duration_percentage] = total_service_duration == 0 ? 0 : ((value[:sum_weighted_service_duration].to_f / total_service_duration.to_f) * 100).round(1)
			end

			return_hash = return_hash.sort_by{|k,v| v[:sum_weighted_service_duration]}.reverse
		end
		
		return_hash
	end
	
	def self.revenue_grouped_by_month
		corporation = self.first.planning.corporation
		revenue_from_insurance = self.where(services: {inside_insurance_scope: true}).group_by_month(:starts_at).sum(:total_credits)
		revenue_from_insurance.map { |key, value| revenue_from_insurance[key] = value * (corporation.invoicing_bonus_ratio || 1) } 
		revenue_from_insurance.map { |key, value| revenue_from_insurance[key] = value * (corporation.credits_to_jpy_ratio || 0) }
		revenue_outside_insurance = self.where(services: {inside_insurance_scope: false}).group_by_month(:starts_at).sum(:total_invoiced)
		total_revenue = {}
		revenue_outside_insurance.map { |key, value| total_revenue[key] = value + (revenue_from_insurance[key] || 0) }
		total_revenue
	end

	private

	def reset_verifications
		self.verified_at = nil 
		self.verifier_id = nil 
		self.second_verified_at = nil 
		self.second_verifier_id = nil
	end

	def remove_second_nurse_if_same_as_nurse
		self.second_nurse_id = nil if second_nurse_id == nurse_id
	end

	def remove_second_nurse_if_requested
		self.second_nurse_id = nil if remove_second_nurse
	end
	
	def request_edit_if_undefined_nurse
		self.edit_requested = true if self.nurse.try(:name) == '未定'
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
			set_credits_invoice_and_wage_to_zero
		elsif self.cancelled? && !self.will_save_change_to_cancelled?
		else
			if self.service.present?
				self.total_credits = self.service.unit_credits
				self.total_invoiced = self.service.invoiced_amount
				calculate_wage_and_second_wage
			else
				set_credits_invoice_and_wage_to_zero
			end
		end
	end

	def set_credits_invoice_and_wage_to_zero
		self.total_credits = 0
		self.total_invoiced = 0
		self.total_wage = 0
		self.second_nurse_wage = 0
	end

	def calculate_wage_and_second_wage
		first_nurse_service_wage = self.service.nurse_service_wages.where(nurse_id: self.nurse_id).first
		if first_nurse_service_wage.present?
			unit_wage_to_apply = self.on_weekend_or_holiday? ? (first_nurse_service_wage.weekend_unit_wage || first_nurse_service_wage.unit_wage || self.service.try(:weekend_unit_wage) || self.service.try(:unit_wage) || 0) : (first_nurse_service_wage.unit_wage || self.service.try(:unit_wage) || 0)
			if self.service.hour_based_wage?
				hour_based_calculation = ((self.duration.to_f / 3600) * unit_wage_to_apply.to_i).round
				if self.service.minimum_wage.present? 
					self.total_wage = hour_based_calculation >= self.service.minimum_wage ?  hour_based_calculation : self.service.minimum_wage
				else
					self.total_wage = hour_based_calculation
				end
			else
				self.total_wage = unit_wage_to_apply.to_i
			end
		else
			unit_wage_to_apply = self.on_weekend_or_holiday? ? (self.service.weekend_unit_wage || self.service.unit_wage || 0) : (self.service.unit_wage || 0)
			if self.service.hour_based_wage?
				hour_based_calculation = ((self.duration.to_f / 3600) * unit_wage_to_apply.to_i).round
				if self.service.minimum_wage.present?
					self.total_wage = hour_based_calculation >= self.service.minimum_wage ? hour_based_calculation : self.service.minimum_wage
				else
					self.total_wage = hour_based_calculation
				end
			else
				self.total_wage = unit_wage_to_apply.to_i
			end
		end
		if self.second_nurse_id.present? && self.service.second_nurse_unit_wage.present? 
			self.second_nurse_wage = self.service.second_nurse_hour_based_wage? ? ((self.duration.to_f / 3600) * self.service.second_nurse_unit_wage.to_i).round : self.service.second_nurse_unit_wage
		end
	end

	def request_edit_for_overlapping_appointments
		overlapping_appointments = Appointment.not_archived.where(nurse_id: self.nurse_id).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).where_recurring_appointment_id_different_from(self.recurring_appointment_id)
		overlapping_appointments.update_all(edit_requested: true, recurring_appointment_id: nil, updated_at: Time.current) if overlapping_appointments.present?
	end

	def do_not_overlap
		nurse = Nurse.find(self.nurse_id)

		unless nurse.name == '未定' || self.archived? || self.edit_requested? || self.cancelled?
			nurse_overlapping_ids = Appointment.with_nurse_or_second_nurse_by_id(self.nurse_id).where(edit_requested: false, planning_id: self.planning_id, archived_at: nil, cancelled: false).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).pluck(:id)
			second_nurse_overlapping_ids = Appointment.with_nurse_or_second_nurse_by_id(self.second_nurse_id).where(edit_requested: false, planning_id: self.planning_id, archived_at: nil, cancelled: false).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).pluck(:id) if second_nurse_id.present? && second_nurse.name != '未定' 

			errors[:base] << "その日の従業員が重複しています。" if nurse_overlapping_ids.present?
			errors[:base] << "その日の同行の従業員が重複しています。" if second_nurse_overlapping_ids.present?
			errors[:overlapping_ids] << (nurse_overlapping_ids || []) + (second_nurse_overlapping_ids || []) if nurse_overlapping_ids.present? || second_nurse_overlapping_ids.present?
		end
	end

end
