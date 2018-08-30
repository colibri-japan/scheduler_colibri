class Patient < ApplicationRecord
	has_many :appointments
	has_many :recurring_appointments
	has_many :unavailabilities
	has_many :recurring_unavailabilities
	has_many :provided_services
	belongs_to :corporation
	
	validates :name, presence: true

	before_save :toggle_deactivate_appointments, if: :will_save_change_to_active?
	before_save :toggle_deactivate_recurring_appointments, if: :will_save_change_to_active?

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }

	private

	def toggle_deactivate_appointments
		puts 'started toggling appointments'
		corporation = self.corporation
		plannings = corporation.plannings

		appointments_to_toggle = Appointment.where(planning_id: plannings.ids, patient_id: self.id, deleted: false, master: false).where("start >= ?", Time.current)
		puts 'appointment ids'
		puts appointments.ids
		appointments_to_toggle.each do |appointment_to_toggle|
			appointment_to_toggle.update(displayable: !appointment_to_toggle.displayable, deactivated: !appointment_to_toggle.deactivated, recurring_appointment_id: nil)
			puts 'toggled active and displayable on appointments an appointment'
		end

		puts 'appointments deactivated'
	end

	def toggle_deactivate_recurring_appointments
		puts 'started toggling recurring appointments'

		corporation = self.corporation
		plannings = corporation.plannings

		recurring_appointments = RecurringAppointment.where(planning_id: plannings.ids, patient_id: self.id, displayable: true, deleted: false, master: true)
		puts 'recurring appointment ids'
		puts recurring_appointments.ids

		recurring_appointments.each do |recurring_appointment|
			recurring_appointment.update(deactivated: !recurring_appointment.deactivated)
		end
	end

end
