class Patient < ApplicationRecord
	has_many :appointments
	has_many :recurring_appointments
	has_many :unavailabilities
	has_many :recurring_unavailabilities
	has_many :provided_services
	belongs_to :corporation
	
	validates :name, presence: true

	before_save :toggle_deactivate_recurring_appointments, if: :will_save_change_to_active?

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }

	private

	def toggle_deactivate_recurring_appointments
		puts 'started toggling recurring appointments'

		corporation = self.corporation
		plannings = corporation.plannings

		recurring_appointments = RecurringAppointment.where(planning_id: plannings.ids, patient_id: self.id, displayable: true, deleted: false, master: true)

		recurring_appointments.each do |recurring_appointment|
			recurring_appointment.update_attribute(:deactivated, !recurring_appointment.deactivated)
		end
	end

end
