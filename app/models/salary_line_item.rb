class SalaryLineItem < ApplicationRecord
	attribute :target_service_ids
	include Archivable

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
	scope :from_salary_rules, -> { where.not(salary_rule_id: nil) }

	def weekend_holiday_salary_line_item?
		!self.service_date.on_weekday? || HolidayJp.between(self.service_date.beginning_of_day, self.service_date.end_of_day).present?
	end

	private

	def set_default_service_counts
	    self.service_counts ||= 1 
	end

	def set_default_duration
		self.service_duration ||= 0
	end

end
