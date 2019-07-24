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

	private

	def set_default_service_counts
	    self.service_counts ||= 1 
	end

	def set_default_duration
		self.service_duration ||= 0
	end

end
