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
	scope :full_timers, -> { where(full_timer: true) }
	scope :part_timers, -> { where(full_timer: false) }

	def self.group_full_timer_for_select
		{
			'正社員' => where(full_timer: true).order_by_kana.map{|nurse| [nurse.name, nurse.id]},
			'非正社員' => where(full_timer: false).order_by_kana.map{|nurse| [nurse.name, nurse.id]}
		}
	end

	def self.master_availabilities_per_slot_and_wday(date)
		monday = date.to_date.beginning_of_week
		days_of_week = [monday, monday + 1.day, monday + 2.days, monday + 3.days, monday + 4.days, monday + 5.days, monday + 6.days]

		return_hash = {}
		slots = [{slot_start: 9, slot_end: 12}, {slot_start: 12, slot_end: 15}, {slot_start: 15, slot_end: 16}]
		slots.each do |slot|
			slot_hash = {}
			days_of_week.each do |day|
				slot_hash[day.wday] = self.available_as_master_in_range(DateTime.new(day.year, day.month, day.day, slot[:slot_start], slot[:slot_end])..DateTime.new(day.year, day.month, day.day, slot[:slot_start], slot[:slot_end])).count
			end
			return_hash[slot] = slot_hash
		end

		return_hash
	end

	def self.available_as_master_in_range(range)
		select {|n| n.is_available_as_master_in_range?(range)}
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
			if nurse.corporation.can_send_reminder_today?(Time.current.in_time_zone('Tokyo')) && nurse.corporation.can_send_reminder_now?(Time.current.in_time_zone('Tokyo'))
				puts 'sending email'
				selected_days = nurse.corporation.reminder_email_days(Time.current.in_time_zone('Tokyo'))
				SendNurseReminderWorker.perform_async(nurse.id, selected_days)
			else 
				puts 'will not send email'
			end
		end
	end

	def self.increment_days_worked_if_has_worked_yesterday
		nurse_ids = Nurse.includes(:provided_services, :appointments).where(provided_services: {cancelled: false, archived_at: nil, service_date: Date.yesterday.beginning_of_day..Date.yesterday.end_of_day}, appointments: {edit_requested: false}).ids
		Nurse.where(id: nurse_ids).update_all("days_worked = days_worked + 1")
	end

end
