class SalaryLineItem < ApplicationRecord
	attribute :target_service_ids

	belongs_to :nurse
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :salary_rule, optional: true

	before_save :set_default_service_counts

	scope :is_verified, -> { where.not(verified_at: nil) }
	scope :unverified, -> { where('verified_at IS NULL AND second_verified_at IS NULL') }
	scope :not_archived, -> { where(archived_at: nil) }
	scope :in_range, -> range { where('service_date BETWEEN ? AND ?', range.first, range.last) }
	scope :not_from_appointments, -> { where('appointment_id IS NULL') }

	def self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |salary_line_item|
				csv << salary_line_item.attributes.values_at(*column_names)
			end
		end
	end

	def weekend_holiday_salary_line_item?
		!self.service_date.on_weekday? || HolidayJp.between(self.service_date.beginning_of_day, self.service_date.end_of_day).present? ? true : false
	end


	def verify(user_id)
		verified_at = Time.current
		verifier_id = user_id
	end

	def second_verify(user_id)
		second_verified_at = Time.current 
		second_verified_id = user_id 
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

	def self.grouped_by_weighted_category(options = {})
		return_hash = {}
		categories = (options[:categories].blank? || options[:categories] == ['null']) ? Array(0..9) : options[:categories]
		categories.map!(&:to_i)
		categories.map {|category| return_hash[category] = {sum_weighted_service_duration: 0, sum_weighted_credits: 0, weighted_service_duration_percentage: 0, sum_weighted_total_wage: 0, sum_count: 0} }

		if self.first.present?
			data_grouped_by_title = self.group(:title).select('salary_line_items.title, sum(salary_line_items.service_duration) as sum_service_duration, sum(salary_line_items.total_wage) as sum_total_wage, sum(salary_line_items.total_credits) as sum_total_credits, count(*)')

			services_without_nurses = Service.where(title: data_grouped_by_title.map(&:title), nurse_id: nil, corporation_id: self.first.planning.corporation.id).pluck(:title, :category_ratio, :category_1, :category_2, :unit_credits)

			data_grouped_by_title.each do |grouped_service|
				service_without_nurse = services_without_nurses.find {|e| e[0] == grouped_service.title }

				if service_without_nurse.present?
					argument = service_without_nurse[1].present? ? service_without_nurse[1] : 1
					if service_without_nurse[2].present? && categories.include?(service_without_nurse[2])
						return_hash[service_without_nurse[2]][:sum_weighted_credits] += (grouped_service.sum_total_credits || 0) * argument || 0
						return_hash[service_without_nurse[2]][:sum_weighted_service_duration] += (grouped_service.sum_service_duration || 0) * argument || 0
						return_hash[service_without_nurse[2]][:sum_weighted_total_wage] += (grouped_service.sum_total_wage || 0) * argument || 0
						return_hash[service_without_nurse[2]][:sum_count] += grouped_service.count || 0
					end
					if service_without_nurse[3].present? && categories.include?(service_without_nurse[3])
						return_hash[service_without_nurse[3]][:sum_weighted_credits] += (grouped_service.sum_total_credits || 0) * (1 - argument) || 0
						return_hash[service_without_nurse[3]][:sum_weighted_service_duration] += (grouped_service.sum_service_duration || 0) * (1 - argument) || 0
						return_hash[service_without_nurse[3]][:sum_weighted_total_wage] += (grouped_service.sum_total_wage || 0) * (1 - argument) || 0
						return_hash[service_without_nurse[3]][:sum_count] += grouped_service.count || 0
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

	private

	def lookup_unit_cost_and_hour_based_wage
		if self.service_salary.present?
			self.unit_cost = self.weekend_holiday_salary_line_item? ? (self.service_salary.weekend_unit_wage || 0) : (self.service_salary.unit_wage || 0)
			self.hour_based_wage = self.service_salary.hour_based_wage
		end
	end

	def set_default_service_counts
	    self.service_counts ||= 1 
	end

	def set_default_duration
		self.service_duration ||= 0
	end

	def calculate_total_wage
		if self.appointment.present? && ((self.cancelled? && self.will_save_change_to_cancelled?) || self.appointment.edit_requested?)
			self.total_wage = 0
		elsif self.cancelled == true && !self.will_save_change_to_cancelled?
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

	def calculate_credits_and_invoiced_amount
		if self.appointment.present? && ((self.cancelled? && self.will_save_change_to_cancelled?) || self.appointment.edit_requested?)
			self.total_credits = 0
			self.invoiced_total = 0
		elsif self.cancelled? && !self.will_save_change_to_cancelled?
		else
			if self.service_salary.present?
				self.total_credits = self.service_salary.unit_credits || 0
				calculate_invoiced_amount
			end
		end
	end

	def calculate_invoiced_amount
		case self.service_salary.insurance_category_1
		when 0
			credits_to_jpy_ratio = (self.nurse.present? && self.nurse.team.present?) ? (self.nurse.team.credits_to_jpy_ratio || self.planning.corporation.credits_to_jpy_ratio || 0) : (self.planning.corporation.credits_to_jpy_ratio || 0)
			self.invoiced_total = ((self.total_credits || 0) * credits_to_jpy_ratio).floor
		when 1
			self.invoiced_total = self.service_salary.invoiced_amount
		else
		end
	end

	def reset_verifications
		self.verified_at = nil 
		self.verifier_id = nil 
		self.second_verified_at = nil 
		self.second_verifier_id = nil
	end

	#def recalculate_salary_line_items_from_salary_rules
	#	if self.appointment_id.present?
	#		RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(self.nurse_id, self.service_date.year, self.service_date.month)
	#	end
	#end


end
