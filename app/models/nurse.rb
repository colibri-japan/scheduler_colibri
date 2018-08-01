class Nurse < ApplicationRecord
	belongs_to :corporation
	has_many :appointments
	has_many :recurring_appointments
	has_many :provided_services

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

end
