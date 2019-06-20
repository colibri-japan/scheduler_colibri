class Nurse < ApplicationRecord
	acts_as_taggable
	acts_as_taggable_on :skills
	attribute :custom_email_message
	attribute :custom_email_days
	attribute :custom_email_subject, :string

	belongs_to :corporation, touch: true
	belongs_to :team, optional: true
	has_many :appointments, dependent: :destroy
	has_many :recurring_appointments, dependent: :destroy
	has_many :provided_services, dependent: :destroy
	has_many :services
	has_many :patients

	validates :name, presence: true

	after_create :create_nurse_services

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :displayable, -> { where(displayable: true) }
	scope :reminderable, -> { where(reminderable: true) }
	scope :full_timers, -> { where(full_timer: true) }
	scope :part_timers, -> { where(full_timer: false) }

	def self.group_full_timer_for_select
		{
			'正社員' => where(full_timer: true).order_by_kana.map{|nurse| [nurse.name, nurse.id]},
			'非正社員' => where(full_timer: false).order_by_kana.map{|nurse| [nurse.name, nurse.id]}
		}
	end

	def self.without_unavailabilities(range)
		unavailable_nurse_ids = WishedSlot.unavailabilities.where(nurse_id: self.ids).occurs_in_range(range).select {|w| w.overlapping_hours(range.first, range.last)}.map(&:nurse_id).uniq

		where.not(id: unavailable_nurse_ids)
	end

	def self.master_availabilities_per_slot_and_wday(date)
		monday = date.to_date.beginning_of_week
		days_of_week = [monday, monday + 1.day, monday + 2.days, monday + 3.days, monday + 4.days, monday + 5.days, monday + 6.days]

		return_hash = {}
		slots = [{slot_start: 9, slot_end: 12}, {slot_start: 12, slot_end: 15}, {slot_start: 15, slot_end: 18}]
		slots.each do |slot|
			slot_hash = {}
			days_of_week.each do |day|
				range_start = DateTime.new(day.year, day.month, day.day, slot[:slot_start], 0)
				range_end = DateTime.new(day.year, day.month, day.day, slot[:slot_end], 0)
				slot_hash[day.wday] = self.available_as_master_in_range(range_start..range_end).count
			end
			return_hash[slot] = slot_hash
		end

		return_hash
	end

	def self.available_as_master_in_range(range)
		return_array = self.without_unavailabilities(range).to_a
		
		recurring_appointments = RecurringAppointment.valid.from_master.where(nurse_id: self.ids).not_terminated_at(range.first).occurs_in_range(range).select {|r| r.overlapping_hours(range.first, range.last)}
		return return_array if recurring_appointments.blank?

		nurses_with_appointments = self.where(id: recurring_appointments.map(&:nurse_id).uniq)

		nurses_with_appointments.each do |nurse|
			nurse_recurring_appointments = recurring_appointments.select {|r| r.nurse_id == nurse.id }
			nurse_shifts = nurse_recurring_appointments.map {|r| {starts_at: DateTime.new(range.first.year, range.first.month, range.first.day, r.starts_at.hour, r.starts_at.min), ends_at: DateTime.new(range.first.year, range.first.month, range.first.day, r.ends_at.hour, r.ends_at.min)} }
			nurse_shifts.sort_by! {|hash| hash[:starts_at]}

			next if ((nurse_shifts.first[:starts_at] - range.first) * 24 * 60 * 60).to_i >= 3600
			next if ((range.last - nurse_shifts.last[:ends_at]) * 24 * 60 * 60).to_i >= 3600

			nurse_shifts.each_with_index do |nurse_shift, index|
				break if index + 1 < nurse_shifts.length && ((nurse_shifts[index + 1][:starts_at] - nurse_shift[:ends_at]) * 24 * 60 * 60 ).to_i >= 3600
			end

			return_array.delete(nurse) if return_array.class.name == 'Array'
		end

		return_array
	end

	def is_available_as_master_in_range?(range)
		nurse_shifts = RecurringAppointment.valid.from_master.where(nurse_id: self.id).not_terminated_at(range.first).occurs_in_range(range).select {|r| r.overlapping_hours(range.first, range.last)}.pluck(:starts_at, :ends_at)
		return true if nurse_shifts.blank?

		nurse_shifts.map! {|array| {starts_at: DateTime.new(range.first.year, range.first.month, range.first.day, array[0].hour, array[0].min), ends_at: DateTime.new(range.first.year, range.first.month, range.first.day, array[1].hour, array[1].min)}}
		nurse_shifts.sort_by! {|hash| hash[:starts_at]}	

		return true if ((nurse_shifts.first[:starts_at] - range.first) * 24 * 60 * 60).to_i >= 3600
		return true if ((range.last - nurse_shifts.last[:ends_at]) * 24 * 60 * 60).to_i >= 3600

		nurse_shifts.each_with_index do |nurse_shift, index|
			return true if index + 1 < nurse_shifts.length && ((nurse_shifts[index + 1][:starts_at] - nurse_shift[:ends_at]) * 24 * 60 * 60 ).to_i >= 3600
		end	
		
		false
	end

	def as_json
		{
			id: id, 
			title: name, 
			is_nurse_resource: true 
		}
	end

	def self.provided_services_count_and_sum_duration_for(range)
		return_array = []

		Nurse.where(id: self.ids).each do |nurse|
			nurse_services_hash = {}
			grouped_provided_services_array = ProvidedService.from_appointments.where(service_date: range, nurse_id: nurse.id, cancelled: false, archived_at: nil).joins(:appointment).where(appointments: {edit_requested: false}).group(:title).pluck('provided_services.title, count(*), sum(provided_services.service_duration) / (60 * 60) as sum_service_duration')
			grouped_provided_services_array.map {|e| nurse_services_hash[e[0]] = {count: e[1], sum_service_duration: e[2]}}
			return_array << [nurse.name, nurse_services_hash]
		end

		return_array
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

	def self.send_service_reminder
		now_in_japan = Time.current.in_time_zone('Tokyo')
		Nurse.where(reminderable: true, displayable: true).includes(:corporation).find_each do |nurse|
			if nurse.corporation.can_send_reminder_today?(now_in_japan) && nurse.corporation.can_send_reminder_now?(now_in_japan)
				selected_days = nurse.corporation.reminder_email_days(now_in_japan)
				SendNurseReminderWorker.perform_async(nurse.id, selected_days)
			end
		end
	end

	def self.increment_days_worked_if_has_worked_yesterday
		Nurse.joins(:provided_services, :appointments).where(provided_services: {cancelled: false, archived_at: nil, service_date: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day}, appointments: {edit_requested: false}).update_all("days_worked = days_worked + 1")
	end

end
