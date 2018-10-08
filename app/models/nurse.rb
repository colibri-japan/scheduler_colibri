class Nurse < ApplicationRecord
	attribute :custom_email_message
	attribute :custom_email_days

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

	def send_service_reminder(custom_email_days, options={})
		@custom_email_message = options[:custom_email_message] || ' '
		@custom_email_days = custom_email_days

		@custom_email_days.map! {|e| e.to_date }

		valid_plannings = Planning.where(business_month: Time.current.month, corporation_id: self.corporation_id)

		selected_appointments = []

		@custom_email_days.each do |custom_day|
			custom_day_start = custom_day.beginning_of_day
			custom_day_end = custom_day.end_of_day
			custom_day_appointments =  Appointment.where(planning_id: valid_plannings.ids, nurse_id: self.id, displayable: true, deactivated: false, edit_requested: false, master: false).where(start: custom_day_start..custom_day_end).all.order(start: 'asc')
			selected_appointments << custom_day_appointments.to_a
		end

		selected_appointments = selected_appointments.flatten

		if selected_appointments.present? && self.phone_mail.present?
			NurseMailer.reminder_email(self, selected_appointments, @custom_email_days, {custom_email_message: @custom_email_message}).deliver_now 
		end

	end
	
	private 



	def self.service_reminder
		Nurse.where(reminderable: true).find_each do |nurse|
			date = Date.today

			selected_days = [1,2,3,4].include?(date.wday) ? [date + 1.day] : [date + 1.day, date + 2.days, date + 3.days]

			nurse.send_service_reminder(selected_days)
		end
	end

end
