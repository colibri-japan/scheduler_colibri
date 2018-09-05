class ProvidedService < ApplicationRecord
	belongs_to :appointment, optional: true
	belongs_to :nurse
	belongs_to :patient, optional: true
	belongs_to :planning

	before_save :lookup_unit_cost
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

	def lookup_unit_cost
		if self.unit_cost.nil? && self.title.present?
			last_similar = ProvidedService.where(nurse_id: self.nurse_id, title: self.title).last 
			self.unit_cost = last_similar.unit_cost if last_similar.present?
		end
	end

	def calculate_total_wage
		if self.hour_based_wage = true
		  if self.unit_cost.present? && self.service_duration.present?
			  self.total_wage = ( self.unit_cost.to_f / 60 ) * ( self.service_duration / 60 )
		  elsif self.service_counts.present? && self.unit_cost.present?
			  self.total_wage = self.service_counts.to_i * self.unit_cost.to_i
		  end
		else
			self.total_wage = self.unit_cost
		end
	end

	def set_countable
		self.countable = false unless self.countable.present?
	end

	def self.master_delete
		provided_services = ProvidedService.all

		provided_services.delete_all
	end


end
