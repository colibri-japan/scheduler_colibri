class ProvidedService < ApplicationRecord
	attribute :target_service_ids
	attribute :skip_callbacks_except_calculate_total_wage, :boolean

	belongs_to :appointment, optional: true
	belongs_to :nurse
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :service_salary, class_name: 'Service', optional: true
	belongs_to :verifier, class_name: 'User', optional: true
	belongs_to :second_verifier, class_name: 'User', optional: true
	belongs_to :salary_rule, optional: true

	before_save :set_default_countable, unless: :skip_callbacks_except_calculate_total_wage
	before_save :lookup_unit_cost_and_hour_based_wage, unless: :skip_callbacks_except_calculate_total_wage
	before_save :service_counts_or_duration_from_target_services,　unless: :skip_callbacks_except_calculate_total_wage
	before_save :set_default_service_counts, unless: :skip_callbacks_except_calculate_total_wage
	before_save :set_default_duration, unless: :skip_callbacks_except_calculate_total_wage
	before_save :calculate_total_wage

	before_update :reset_verifications, unless: :verifying_provided_service

	after_update :recalculate_provided_services_from_salary_rules, unless: :skip_callbacks_except_calculate_total_wage


	scope :provided, -> { where(provided: true) }
	scope :is_verified, -> { where.not(verified_at: nil) }
	scope :not_archived, -> { where(archived_at: nil) }
	scope :in_range, -> range { where('service_date BETWEEN ? AND ?', range.first, range.last) }
	scope :from_salary_rules, -> { where('salary_rule_id IS NOT NULL') }
	scope :from_appointments, -> { where('appointment_id IS NOT NULL') }

	def self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |provided_service|
				csv << provided_service.attributes.values_at(*column_names)
			end
		end
	end

	def weekend_holiday_provided_service?
		!self.service_date.on_weekday? || HolidayJp.between(self.service_date.beginning_of_day, self.service_date.end_of_day).present? ? true : false
	end

	def verified?
		verified_at.present?
	end

	def second_verified?
		second_verified_at.present? 
	end

	def verify(user_id)
		verified_at = Time.current
		verifier_id = user_id
	end

	def second_verify(user_id)
		second_verified_at = Time.current 
		second_verified_id = user_id 
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

	def verifying_provided_service
		will_save_change_to_verified_at? || will_save_change_to_second_verified_at?
	end

	def archived?
		archived_at.present?
	end

	def archive 
		archived_at = Time.current 
	end

	def archive! 
		update_column(:archived_at, Time.current)
	end

	private

	def set_default_countable
		self.countable ||= false 
	end

	def lookup_unit_cost_and_hour_based_wage
		if self.service_salary.present?
			self.unit_cost = self.weekend_holiday_provided_service? ? self.service_salary.weekend_unit_wage : self.service_salary.unit_wage
			self.hour_based_wage = self.service_salary.hour_based_wage
		end
	end

	def service_counts_or_duration_from_target_services
		if  self.target_service_ids.present? && self.service_counts.nil? && self.service_duration.nil?
			puts 'inside service_counts'
			services = target_service_ids.map{|id| Service.find(id) if id.present?}.compact
			if self.hour_based_wage == true 
				sum_hours = 0
				services.each do |service|
					provided_services = ProvidedService.where(planning_id: self.planning_id, title: service.title, provided: true, nurse_id: self.nurse_id, cancelled: false)
					provided_service_sum_duration = provided_services.sum(:service_duration) || 0
					sum_hours = sum_hours + provided_service_sum_duration
				end
				self.service_duration = sum_hours
			else
				sum_count = 0
				services.each do |service|
					provided_services = ProvidedService.where(planning_id: self.planning_id, title: service.title, provided: true, nurse_id: self.nurse_id, cancelled: false)
					sum_count = sum_count + provided_services.sum{|provided_service| provided_service.service_counts.present? ? provided_service.service_counts : 1 }
				end
				self.service_counts = sum_count 
			end
		end
	end

	def set_default_service_counts
	    self.service_counts ||= 1 
	end

	def set_default_duration
		self.service_duration ||= 0
	end

	def calculate_total_wage
		if self.appointment.present? && (self.appointment.cancelled == true || self.appointment.edit_requested == true)
			self.total_wage = 0
		else 
			calculate_wage
		end
	end

	def calculate_wage
		if hour_based_wage == true && unit_cost.present? && service_duration.present?
			self.total_wage = ( unit_cost.to_f / 60 ) * ( service_duration / 60 )
		elsif hour_based_wage == false && service_counts.present? && unit_cost.present? 
			self.total_wage = unit_cost * service_counts
		end
	end

	def reset_verifications
		self.verified_at = nil 
		self.verifier_id = nil 
		self.second_verified_at = nil 
		self.second_verifier_id = nil
	end

	def recalculate_provided_services_from_salary_rules
		RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(self.id)
	end


end
