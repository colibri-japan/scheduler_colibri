class ProvidedService < ApplicationRecord
	belongs_to :appointment, optional: true
	belongs_to :nurse
	belongs_to :patient, optional: true
	belongs_to :planning

	before_save :lookup_hourly_wage
	before_save :calculate_total_wage
	before_save :set_countable

	def self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |provided_service|
				csv << provided_service.attributes.values_at(*column_names)
			end
		end
	end


	private

	def self.add_title
		@provided_services = ProvidedService.all 

		@provided_services.each do |provided_service|
			payable = provided_service.payable
			provided_service.update(title: payable.title) if payable.present?
		end
	end

	def lookup_hourly_wage
		if self.hourly_wage.nil? && self.title.present?
			last_similar = ProvidedService.where(nurse_id: self.nurse_id, title: self.title).last 
			self.hourly_wage = last_similar.hourly_wage if last_similar.present?
		end
	end

	def calculate_total_wage
		if self.hourly_wage.present? && self.service_duration.present?
			self.total_wage = ( self.hourly_wage.to_f / 60 ) * ( self.service_duration / 60 )
		elsif self.service_counts.present? && self.hourly_wage.present?
			self.total_wage = self.service_counts.to_i * self.hourly_wage.to_i
		end
	end

	def set_countable
		self.countable = false unless self.countable.present?
	end

end
