class ProvidedService < ApplicationRecord
	belongs_to :payable, polymorphic: true
	belongs_to :nurse
	belongs_to :patient

	before_save :calculate_total_wage

	private

	def calculate_total_wage
		if self.hourly_wage.present? && self.service_duration.present?
			self.total_wage = ( self.hourly_wage.to_f / 60 ) * ( self.service_duration / 60 )
		end
	end
end
