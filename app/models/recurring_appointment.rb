class RecurringAppointment < ApplicationRecord
	include PublicActivity::Common
	# tracked owner: Proc.new{ |controller, model| controller.current_user }
	# tracked planning_id: Proc.new{ |controller, model| model.planning_id }

	
	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'RecurringAppointment', optional: true
	has_many :provided_services, as: :payable
	has_many :deleted_occurrences

	before_save :default_frequency
	before_save :default_master
	before_save :default_displayable

	validates :anchor, presence: true
	validates :frequency, presence: true
	validates :frequency, inclusion: 0..2

	#frequencies : 0 for weekly, 1 for biweekly, 2 for one timer

	def schedule
		@schedule ||= begin
			
		schedule = IceCube::Schedule.new(now = anchor)
			case frequency
			when 0
				schedule.add_recurrence_rule IceCube::Rule.weekly(1)
			when 1
				schedule.add_recurrence_rule IceCube::Rule.weekly(2)
			else
			end
			schedule
		end

	end

	def all_day_recurring_appointment?
		self.start == self.start.midnight && self.end == self.end.mignight ? true : false
	end

	def appointments(start_date, end_date)
		start_frequency = start_date ? start_date.to_date : Date.today - 1.year
		end_frequency = end_date ? end_date.to_date : Date.today + 1.year

		deleted_occurrences = self.deleted_occurrences.map { |d| d.deleted_day }
		initial_occurrences = schedule.occurrences_between(start_frequency, end_frequency)
		initial_occurrences.map! {|occurrence| occurrence.to_date }

		initial_occurrences - deleted_occurrences
	end


	private

	def self.count_as_payable
		recurring_appointments = RecurringAppointment.where(displayable: true, anchor: Time.now.beginning_of_month..Time.now.end_of_month).all



		date = Date.today
		timezone = ActiveSupport::TimeZone['Asia/Tokyo']
		start_time = timezone.local(date.year, date.month, date.day)

		end_time = start_time.end_of_day


		recurring_appointments.each do |recurring_appointment|

			occurrences = recurring_appointment.appointments(start_time, end_time)

			unless occurrences.blank?
				duration = recurring_appointment.end - recurring_appointment.start
				provided = ProvidedService.create!(payable: recurring_appointment, service_duration: duration, nurse_id: recurring_appointment.nurse_id, patient_id: recurring_appointment.patient_id, planning_id: recurring_appointment.planning_id)
			end
		end

	end

	def default_frequency
		self.frequency =0 if self.frequency.nil?
	end

	def default_master
		self.master = true if self.master.nil?
	end

	def default_displayable
		self.displayable = true if self.displayable.nil?
	end
end
