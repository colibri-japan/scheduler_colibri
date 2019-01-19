class Corporation < ApplicationRecord
	has_many :users
	has_one :planning
	has_many :nurses
	has_many :patients
	has_many :services
	has_many :invoice_settings
	has_many :posts
	has_many :teams
	has_one :printing_option

	validates :weekend_reminder_option, inclusion: 0..2

	before_save :set_default_equal_salary
	after_create :create_undefined_nurse
	after_create :create_printing_option

	def self.add_undefined_nurse
		corporations = Corporation.all

		corporations.each do |corporation|
			corporation.nurses.create(name: "未定", displayable: false, kana: "あああああ")
		end
	end

	def reminder_email_days(date)
		if self.weekend_reminder_option == 0
			[1,2,3,4].include?(date.wday) ? [date + 1.day] : [date + 1.day, date + 2.days, date + 3.days]
		elsif self.weekend_reminder_option == 1
			[1,2,3,4,5].include?(date.wday) ? [date + 1.day] : [date + 1.day, date + 2.days]
		elsif self.weekend_reminder_option == 2
			[date + 1.day]
		end
	end

	def can_send_reminder_today?(date)
		if self.weekend_reminder_option == 0
			[1,2,3,4,5].include?(date.wday)
		elsif self.weekend_reminder_option == 1
			[1,2,3,4,5,6].include?(date.wday)
		elsif self.weekend_reminder_option == 2
			true
		end
	end

	def can_send_reminder_now?(datetime)
		parsed_reminder_hour = Time.parse(self.reminder_email_hour)
		valid_reminder_datetime = DateTime.new(datetime.year, datetime.month, datetime.day, parsed_reminder_hour.hour, parsed_reminder_hour.min, 0, '+9')
		puts 'datetime and valid reminder'
		puts datetime 
		puts valid_reminder_datetime
		datetime.between?((valid_reminder_datetime - 15.minutes), (valid_reminder_datetime + 15.minutes))
	end

	#to be deleted 
	def self.add_printing_option
		corporations = Corporation.all 
		corporations.each do |corporation|
			if corporation.printing_option.nil?
				PrintingOption.create(corporation_id: corporation.id) 
			end
		end
	end

	private

	def set_default_equal_salary
		self.equal_salary ||= false
	end

	def create_undefined_nurse
		self.nurses.create(name: "未定", displayable: false, kana: "あああああ")
	end

	def create_printing_option
		PrintingOption.create(corporation_id: self.id)
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

	def self.create_nurse_services
		corporations = Corporation.all 

		corporations.each do |corporation|
			if corporation.equal_salary == false 
				nurses= corporation.nurses.where(displayable: true).all 
				services = corporation.services.all 

				nurses.each do |nurse|
					services.each do |service|
						new_service = service.dup 
						new_service.nurse_id = nurse.id 
						new_service.skip_create_nurses_callback = true

						new_service.save!
					end
				end
			end
		end
	end

	def self.update_services_with_booleans
		Corporation.all.each do |corporation|
			corporation.services.update_all(equal_salary: corporation.equal_salary)
			corporation.services.update_all(hour_based_wage: corporation.hour_based_payroll)
		end
	end

end
