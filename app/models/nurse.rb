class Nurse < ApplicationRecord
	include Archivable

	acts_as_taggable
	acts_as_taggable_on :skills
	acts_as_taggable_on :wishes
	acts_as_taggable_on :wished_areas

	attribute :custom_email_message
	attribute :custom_email_days
	attribute :custom_email_subject, :string

	belongs_to :corporation, touch: true
	belongs_to :team, optional: true, touch: true
	has_many :appointments, dependent: :destroy
	has_many :private_events
	has_many :recurring_appointments, dependent: :destroy
	has_many :salary_line_items, dependent: :destroy
	has_many :patients
	has_many :nurse_service_wages

	validates :name, presence: true

	before_create :set_default_profession

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :displayable, -> { where(displayable: true) }
	scope :reminderable, -> { where(reminderable: true) }
	scope :full_timers, -> { where(full_timer: true) }
	scope :part_timers, -> { where(full_timer: false) }
	scope :not_archived, -> { where(archived_at: nil) }

	def self.without_appointments_between(start_time, end_time, margin)
		start_time -= margin.to_i.minutes 
		end_time += margin.to_i.minutes 

		where.not(id: self.left_outer_joins(:appointments).where('appointments.starts_at between ? and ? OR appointments.ends_at between ? and ? OR (appointments.starts_at < ? AND appointments.ends_at > ?)', start_time, end_time, start_time, end_time, start_time, end_time).ids.uniq)
	end
	
	def self.without_private_events_between(start_time, end_time, margin)
		start_time -= margin.to_i.minutes 
		end_time += margin.to_i.minutes
		where.not(id: self.left_outer_joins(:private_events).where('private_events.starts_at between ? and ? OR private_events.ends_at between ? and ? OR (private_events.starts_at < ? AND private_events.ends_at > ?)', start_time, end_time, start_time, end_time, start_time, end_time).ids.uniq)
	end

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
		
		recurring_appointments = RecurringAppointment.not_archived.where(nurse_id: self.ids).not_terminated_at(range.first).occurs_in_range(range).select {|r| r.overlapping_hours(range.first, range.last)}
		return return_array if recurring_appointments.blank?

		nurses_with_appointments = self.where(id: recurring_appointments.map(&:nurse_id).uniq)

		nurses_with_appointments.each do |nurse|
			nurse_recurring_appointments = recurring_appointments.select {|r| r.nurse_id == nurse.id }
			nurse_shifts = nurse_recurring_appointments.map {|r| {starts_at: DateTime.new(range.first.year, range.first.month, range.first.day, r.starts_at.hour, r.starts_at.min), ends_at: DateTime.new(range.first.year, range.first.month, range.first.day, r.ends_at.hour, r.ends_at.min)} }
			nurse_shifts.sort_by! {|hash| hash[:starts_at]}

			next if ((nurse_shifts.first[:starts_at] - range.first) * 24 * 60 * 60).to_i >= 5400
			next if ((range.last - nurse_shifts.last[:ends_at]) * 24 * 60 * 60).to_i >= 5400

			nurse_shifts.each_with_index do |nurse_shift, index|
				break if index + 1 < nurse_shifts.length && ((nurse_shifts[index + 1][:starts_at] - nurse_shift[:ends_at]) * 24 * 60 * 60 ).to_i >= 5400
			end

			return_array.delete(nurse) if return_array.class.name == 'Array'
		end

		return_array
	end

	def is_available_as_master_in_range?(range)
		nurse_shifts = RecurringAppointment.valid.where(nurse_id: self.id).not_terminated_at(range.first).occurs_in_range(range).select {|r| r.overlapping_hours(range.first, range.last)}.pluck(:starts_at, :ends_at)
		return true if nurse_shifts.blank?

		nurse_shifts.map! {|array| {starts_at: DateTime.new(range.first.year, range.first.month, range.first.day, array[0].hour, array[0].min), ends_at: DateTime.new(range.first.year, range.first.month, range.first.day, array[1].hour, array[1].min)}}
		nurse_shifts.sort_by! {|hash| hash[:starts_at]}	

		return true if ((nurse_shifts.first[:starts_at] - range.first) * 24 * 60 * 60).to_i >= 5400
		return true if ((range.last - nurse_shifts.last[:ends_at]) * 24 * 60 * 60).to_i >= 5400

		nurse_shifts.each_with_index do |nurse_shift, index|
			return true if index + 1 < nurse_shifts.length && ((nurse_shifts[index + 1][:starts_at] - nurse_shift[:ends_at]) * 24 * 60 * 60 ).to_i >= 5400
		end	
		
		false
	end

	def as_json
		{
			id: "nurse_#{id}", 
			title: name,
			model_name: 'nurse',
			record_id: id
		}
	end

	def self.appointments_count_and_sum_duration_for(range)
		return_array = []

		Nurse.where(id: self.ids).each do |nurse|
			nurse_services_hash = {}
			grouped_appointments_array = nurse.appointments.in_range(range).operational.group(:title).pluck('appointments.title, count(*), sum(appointments.duration)::decimal / 3600 as sum_duration')
			grouped_appointments_array.map {|e| nurse_services_hash[e[0]] = {count: e[1], sum_duration: e[2]}}
			return_array << [nurse.name, nurse_services_hash]
		end

		return_array
	end

	def days_worked_at(date, options = {})
		if options[:inside_insurance_scope].present? && options[:inside_insurance_scope] == true
			(days_worked || 0) + self.appointments.operational.joins(:service).where(services: {inside_insurance_scope: true}).where('starts_at <= ?', date.end_of_day).pluck(:starts_at).map(&:to_date).uniq.size
		else
			(days_worked || 0) + self.appointments.operational.where('starts_at <= ?', date.end_of_day).pluck(:starts_at).map(&:to_date).uniq.size
		end
	end

	def days_worked_in_range(range)
		self.appointments.operational.in_range(range).pluck(:starts_at).map(&:to_date).uniq.size
	end

	def date_from_work_day_number(day_number, options = {})
		if options[:inside_insurance_scope].present? && options[:inside_insurance_scope] == true
			dates_array = self.appointments.operational.joins(:service).where(services: {inside_insurance_scope: true}).order(:starts_at).pluck(:starts_at).map(&:to_date).uniq
		else
			dates_array = self.appointments.operational.order(:starts_at).pluck(:starts_at).map(&:to_date).uniq
		end
		
		if day_number <= days_worked
			(dates_array[0]).to_date - 1.day
		elsif day_number > days_worked && (day_number.to_i - (days_worked || 0)) <= dates_array.size
			dates_array[day_number.to_i - (days_worked || 0) - 1]
		elsif day_number > dates_array.size + (days_worked || 0)
			(dates_array[-1]).to_date + 1.day
		else
			Date.today
		end
	end

	def date_from_worked_months(worked_months)
		contract_date.present? ? (contract_date + (worked_months.to_i).months).to_date : (created_at + (worked_months.to_i).months).to_date
	end

	
	private 

	def set_default_profession
		#defaults to 'other'
		self.profession ||= 4
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
end
