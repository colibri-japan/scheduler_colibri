class Corporation < ApplicationRecord
	has_many :users
	has_many :plannings
	has_many :nurses
	has_many :patients
	has_many :services
	has_many :invoice_settings

	before_save :set_default_equal_salary
	after_create :create_undefined_nurse

	def self.add_undefined_nurse
		corporations = Corporation.all

		corporations.each do |corporation|
			corporation.nurses.create(name: "未定", displayable: false, kana: "あああああ")
		end
	end

	private

	def set_default_equal_salary
		self.equal_salary ||= false
	end

	def create_undefined_nurse
		self.nurses.create(name: "未定", displayable: false, kana: "あああああ")
	end

	def self.add_services
		corporations = Corporation.all 

		corporations.each do |corporation|
			plannings = corporation.plannings

			appointments = Appointment.where(planning_id: plannings.ids, master: true)

			appointments.each do |appointment|
				existing_service = corporation.services.where(title: appointment.title)

				unless existing_service.present?
					new_service = corporation.services.create(title: appointment.title)
				end
			end

		end
	end

	def self.create_weekend_holiday_invoice_setting
		corporations=Corporation.all 

		corporations.each do |corporation|
			existing_rule = InvoiceSetting.where(corporation_id: corporation.id, target_services_by_1: 1)

			unless existing_rule.present?
				corporation.invoice_settings.create(title: '土日祝日手当', target_services_by_1: 1, invoice_line_option: 0, operator: 1, argument: 1, hour_based: false)
			end
		end
	end

	def self.organize_services
		corporations = Corporation.all 
		corporations.each do |corporation|
			if corporation.equal_salary == true
				services = corporation.services.all 

				services.each do |service|
					provided_services = ProvidedService.where(title: service.title).where.not(unit_cost: nil)

					if provided_services.present? 
						unit_wage =  provided_services.first.unit_cost
						rule = InvoiceSetting.where(corporation_id: provided_services.first.planning.corporation.id, target_services_by_1: 1).take
						weekend_unit_wage = unit_wage * rule.argument if rule.present?
						service.update(unit_wage: unit_wage, weekend_unit_wage: weekend_unit_wage)
					end
				end
			else
				@services = corporation.services.all 
				@nurses = corporation.nurses.where(displayable: true).all
				
				@services.each do |service|
					

					@nurses.each do |nurse|
						new_service = service.dup
						new_service.nurse_id = nurse.id 

						provided_services = ProvidedService.where(title: service.title, nurse_id: nurse.id).where.not(unit_cost: nil)
						if provided_services.present? 
							unit_wage =  provided_services.first.unit_cost
							rule = InvoiceSetting.where(corporation_id: provided_services.first.planning.corporation.id, target_services_by_1: 1).take
							weekend_unit_wage = unit_wage * rule.argument if rule.present?
							new_service.unit_wage = unit_wage 
							new_service.weekend_unit_wage = weekend_unit_wage
						end
						new_service.save!
					end
				end

			end
		end
	end

end
