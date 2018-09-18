class Nurse < ApplicationRecord
	belongs_to :corporation
	has_many :appointments, dependent: :destroy
	has_many :recurring_appointments, dependent: :destroy
	has_many :provided_services, dependent: :destroy
	has_many :invoice_setting_nurses
	has_many :nurses, through: :invoice_setting_nurses

	validates :name, presence: true

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }


	def self.service_reminder
		nurses = Nurse.where(reminderable: true)

		start_time = DateTime.now.beginning_of_day
		end_time = DateTime.now.end_of_day

		valid_plannings = Planning.where(business_month: start_time.month)

		nurses.each do |nurse|
			# find all relevant appointments
			nurse_appointments = RecurringAppointment.where(planning_id: valid_plannings.ids, nurse_id: nurse.id, displayable: true).order("to_char(start, 'HH24:MM:SS') ASC")

			# select the appointments that occur today
			todays_appointments = []
			nurse_appointments.each do |appointment|
				occurrences = appointment.appointments(start_time, end_time)
				todays_appointments << appointment if occurrences.present?
			end

			#send an email to the nurse with all the information
			if todays_appointments.present? && nurse.phone_mail.present?
				NurseMailer.reminder_email(nurse, todays_appointments).deliver_now
			end
		end
	end

	def self.group_full_timer_for_select
		{
			'正社員' => where(full_timer: true).order_by_kana.map{|nurse| [nurse.name, nurse.id]},
			'非正社員' => where(full_timer: false).order_by_kana.map{|nurse| [nurse.name, nurse.id]}
		}
    end

end
