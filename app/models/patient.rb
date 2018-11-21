class Patient < ApplicationRecord
	acts_as_taggable
	acts_as_taggable_on :caveats

	has_many :appointments
	has_many :recurring_appointments
	has_many :unavailabilities
	has_many :recurring_unavailabilities
	has_many :provided_services
	belongs_to :corporation
	
	validates :name, presence: true

	before_save :cancel_recurring_appointments, if: :will_save_change_to_active?

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :active, -> { where(active: true) }

	private

	def cancel_recurring_appointments
		puts 'started toggling recurring appointments'

		valid_plannings = self.corporation.plannings.where('business_month >= ? AND business_year >= ?', Time.current.month, Time.current.year)

		Appointment.valid.where(patient_id: self.id).where('starts_at > ?', Time.current).update_all(cancelled: true)
		ProvidedService.where('service_date > ?', Time.current).where(patient_id: self.id).update_all(cancelled: true)
		RecurringAppointment.valid.from_master.where(planning_id: valid_plannings.ids, patient_id: self.id).update_all(cancelled: true)

	end

end
