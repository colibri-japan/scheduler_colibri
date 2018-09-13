class ProvidedService < ApplicationRecord
	attribute :target_service_ids

	belongs_to :appointment, optional: true
	belongs_to :nurse
	belongs_to :patient, optional: true
	belongs_to :planning

	before_save :lookup_unit_cost
	before_save :counts_or_duration_from_target_service_ids
	before_save :default_service_counts
	before_save :default_duration
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

	def counts_or_duration_from_target_service_ids
		if self.target_service_ids.present? 
			puts 'entered validation for target service_ids'
			services = target_service_ids.map{|id| Service.find(id) if id.present?}.compact
			if self.hour_based_wage == true 
				sum_hours = 0
				services.each do |service|
					provided_services = ProvidedService.where(planning_id: self.planning_id, title: service.title, provided: true, nurse_id: self.nurse_id)
					sum_hours = sum_hours + provided_services.sum{|provided_service| provided_service.service_duration.present? ? provided_service.service_duration : 0 }
				end
				self.service_duration = sum_hours
			else
				sum_count = 0
				services.each do |service|
					provided_services = ProvidedService.where(planning_id: self.planning_id, title: service.title, provided: true, nurse_id: self.nurse_id)
					sum_count = provided_services.sum{|provided_service| provided_service.service_counts.present? ? provided_service.service_counts : 0 }
				end
				self.service_counts = sum_count 
			end
		end
	end

	def default_service_counts
		if self.hour_based_wage == false && self.service_counts.nil?
			self.service_counts = 1
		end
	end

	def default_duration
		if self.service_duration.nil?
			self.service_duration = 0
		end
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

	def set_countable
		self.countable = false unless self.countable.present?
	end

	def self.master_delete
		provided_services = ProvidedService.all

		provided_services.delete_all
	end

	def self.add_service_date
		provided_services = ProvidedService.where(service_date: nil, temporary: false, countable: false).where.not(appointment_id: nil)

		provided_services.each do |service|
			appointment = Appointment.find(service.appointment_id)
			puts 'appointment loaded'
			puts appointment

			if appointment.present?
				puts 'within appointment present'
			  service.service_date = service.appointment.end
			  service.appointment_start = service.appointment.start 
			  service.appointment_end = service.appointment.end

			  service.save
			end
		end
	end

	def self.set_default_duration_to_zero
		puts 'add to services'
		provided_services = ProvidedService.where(service_duration: nil, temporary: false)

		provided_services.each do |provided_service|
			provided_service.update(service_duration: 0)
		end
	end


end
