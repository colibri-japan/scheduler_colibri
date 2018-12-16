class Nurse < ApplicationRecord
	acts_as_taggable
	acts_as_taggable_on :skills
	attribute :custom_email_message
	attribute :custom_email_days
	attribute :custom_email_subject, :string

	belongs_to :corporation
	belongs_to :team, optional: true
	has_many :appointments, dependent: :destroy
	has_many :recurring_appointments, dependent: :destroy
	has_many :provided_services, dependent: :destroy
	has_many :invoice_setting_nurses
	has_many :nurses, through: :invoice_setting_nurses
	has_many :services

	validates :name, presence: true

	after_create :create_nurse_services

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :displayable, -> { where(displayable: true) }
	scope :full_timers, -> { where(full_timer: true) }
	scope :part_timers, -> { where(full_timer: false) }

	def self.group_full_timer_for_select
		{
			'正社員' => where(full_timer: true).order_by_kana.map{|nurse| [nurse.name, nurse.id]},
			'非正社員' => where(full_timer: false).order_by_kana.map{|nurse| [nurse.name, nurse.id]}
		}
	end

	
	private 

	def create_nurse_services 
		if Service.where(corporation_id: self.corporation_id, nurse_id: nil).exists?
			services_array = []
			Service.where(corporation_id: self.corporation_id, nurse_id: nil).each do |service|
				new_service = service.dup 
				new_service.nurse_id = self.id 
				services_array << new_service
			end
			Service.import services_array
		end
	end



	def self.service_reminder
		Nurse.where(reminderable: true, displayable: true).find_each do |nurse|
			puts nurse.corporation.can_send_reminder_today?(Date.today)
			puts nurse.corporation.can_send_reminder_now?(Time.current)
			if nurse.corporation.can_send_reminder_today?(Date.today) && nurse.corporation.can_send_reminder_now?(Time.current)
				puts 'will send email'
				selected_days = nurse.corporation.reminder_email_days(Date.today)
				SendNurseReminderWorker.perform_async(nurse.id, selected_days)
			else 
				puts 'will not send email'
			end
		end
	end

end
