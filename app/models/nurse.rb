class Nurse < ApplicationRecord
	attribute :custom_email_message

	belongs_to :corporation
	has_many :appointments, dependent: :destroy
	has_many :recurring_appointments, dependent: :destroy
	has_many :provided_services, dependent: :destroy
	has_many :invoice_setting_nurses
	has_many :nurses, through: :invoice_setting_nurses
	has_many :services

	validates :name, presence: true

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }

	def self.group_full_timer_for_select
		{
			'正社員' => where(full_timer: true).order_by_kana.map{|nurse| [nurse.name, nurse.id]},
			'非正社員' => where(full_timer: false).order_by_kana.map{|nurse| [nurse.name, nurse.id]}
		}
	end
	
	private 

	def send_service_reminder(options={})

		@custom_email_message = options[:custom_email_message] || ' '

		start_time = Time.current.beginning_of_day
		end_time = Time.current.end_of_day

		valid_plannings = Planning.where(business_month: start_time.month, corporation_id: self.corporation_id)

		if [1,2,3,4].include?(start_time.wday)
			next_day_appointments = Appointment.where(planning_id: valid_plannings.ids, nurse_id: self.id, displayable: true, deactivated: false, edit_requested: false, master: false).where(start: (start_time + 1.day)..(end_time + 1.day)).order(start: 'asc')

			if next_day_appointments.present? && self.phone_mail.present?
				NurseMailer.reminder_email(self, next_day_appointments, @custom_email_message).deliver_now
			end
		elsif start_time.wday == 5 
			next_three_day_appointments = Appointment.where(planning_id: valid_plannings.ids, nurse_id: self.id, displayable: true, deactivated: false, edit_requested: false, master: false).where(start: (start_time + 1.day)..(end_time + 3.days)).order(start: 'asc')

			if next_three_day_appointments.present? && self.phone_mail.present?
				NurseMailer.reminder_email(self, next_three_day_appointments, @custom_email_message).deliver_now 
			end
		end
	end

	def self.service_reminder
		nurses = Nurse.where(reminderable: true)

		nurses.each do |nurse|
			nurse.send_service_reminder
		end
	end

end
