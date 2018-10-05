class ProvidedService < ApplicationRecord
	attribute :target_service_ids
	attribute :skip_callbacks_except_calculate_total_wage, :boolean

	belongs_to :appointment, optional: true
	belongs_to :nurse
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :invoice_setting, optional: true


	before_save :set_default_countable, unless: :skip_callbacks_except_calculate_total_wage
	before_save :lookup_unit_cost, unless: :skip_callbacks_except_calculate_total_wage
	before_save :service_counts_or_duration_from_target_services,　unless: :skip_callbacks_except_calculate_total_wage
	before_save :set_default_service_counts, unless: :skip_callbacks_except_calculate_total_wage
	before_save :set_default_duration, unless: :skip_callbacks_except_calculate_total_wage
	before_save :calculate_total_wage

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


	private

	def set_default_countable
		self.countable ||= false 
	end

	def lookup_unit_cost
		if self.service_date.present? && self.temporary == false
			if self.planning.corporation.equal_salary == true 
				@pricing_policy = Service.where(title: self.title, corporation_id: self.planning.corporation.id).first
			else
				@pricing_policy = Service.where(title: self.title, corporation_id: self.planning.corporation.id, nurse_id: self.nurse_id).first
			end

			if @pricing_policy.present?
				self.unit_cost = self.weekend_holiday_provided_service? ? @pricing_policy.weekend_unit_wage : @pricing_policy.unit_wage
			end
		end

	end

	def service_counts_or_duration_from_target_services
		if  self.target_service_ids.present? && self.service_counts.nil? && self.service_duration.nil?
			puts 'inside service_counts'
			services = target_service_ids.map{|id| Service.find(id) if id.present?}.compact
			if self.hour_based_wage == true 
				sum_hours = 0
				services.each do |service|
					provided_services = ProvidedService.where(planning_id: self.planning_id, title: service.title, provided: true, nurse_id: self.nurse_id, deactivated: false)
					sum_hours = sum_hours + provided_services.sum{|provided_service| provided_service.service_duration.present? ? provided_service.service_duration : 0 }
				end
				self.service_duration = sum_hours
			else
				sum_count = 0
				services.each do |service|
					provided_services = ProvidedService.where(planning_id: self.planning_id, title: service.title, provided: true, nurse_id: self.nurse_id, deactivated: false)
					sum_count = sum_count + provided_services.sum{|provided_service| provided_service.service_counts.present? ? provided_service.service_counts : 1 }
				end
				self.service_counts = sum_count 
			end
		else
		end
	end

	def set_default_service_counts
	    self.service_counts ||= 1 
	end

	def set_default_duration
		self.service_duration ||= 0
	end


	def calculate_total_wage
		if self.hour_based_wage == true
		  if self.unit_cost.present? && self.service_duration.present?
			  self.total_wage = ( self.unit_cost.to_f / 60 ) * ( self.service_duration / 60 )
		  elsif self.service_counts.present? && self.unit_cost.present?
			  self.total_wage = self.service_counts.to_i * self.unit_cost.to_i
		  end
		else
			if self.service_counts.present? && self.unit_cost.present?
				self.total_wage = self.unit_cost * self.service_counts
			else 
				self.total_wage = self.unit_cost
			end
		end
	end


end
