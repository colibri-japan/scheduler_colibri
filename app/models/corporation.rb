class Corporation < ApplicationRecord
	has_many :users
	has_one :planning
	has_many :nurses
	has_many :patients
	has_many :services
	has_many :posts
	has_many :teams
	has_one :printing_option
	has_many :salary_rules
	has_many :care_manager_corporations

	validates :weekend_reminder_option, inclusion: 0..2

	after_create :create_undefined_nurse
	after_create :create_printing_option
	after_commit :flush_cache


	def reminder_email_days(date)
		if self.weekend_reminder_option == 0
			[1,2,3,4].include?(date.wday) ? [date + 1.day] : [date + 1.day, date + 2.days, date + 3.days]
		elsif self.weekend_reminder_option == 1
			[1,2,3,4,5].include?(date.wday) ? [date + 1.day] : [date + 1.day, date + 2.days]
		elsif self.weekend_reminder_option == 2
			[date + 1.day]
		end
	end

	def cached_recent_posts
		Rails.cache.fetch([self, 'recent_posts']) { posts.includes(:author, :patients, :reminders).order(published_at: :desc).limit(40) }
	end

	def cached_active_patients_grouped_by_kana
		Rails.cache.fetch([self, 'active_patients_grouped_by_kana']) { patients.active.group_by_kana }
	end

	def cached_inactive_patients_ordered_by_kana
		Rails.cache.fetch([self, 'inactive_patients_ordered_by_kana']) { patients.deactivated.order_by_kana }
	end

	def cached_active_patients_ordered_by_kana
		Rails.cache.fetch([self, 'active_patients_ordered_by_kana']) { patients.active.order_by_kana }
	end

	def cached_all_patients_ordered_by_kana
		Rails.cache.fetch([self, 'patients_ordered_by_kana']) { patients.order_by_kana }
	end

	def cached_registered_users_ordered_by_kana
		Rails.cache.fetch([self, 'registered_users_ordered_by_kana']) { users.registered.order_by_kana }
	end

	def cached_displayable_nurses_grouped_by_team_name
		Rails.cache.fetch([self, 'displayable_nurses_grouped_by_team_name']) { 
			team_name_by_id = self.teams.pluck(:id, :team_name).to_h
			return nurses.displayable.order_by_kana.group_by {|n| team_name_by_id[n.team_id] }
		}
	end

	def cached_displayable_nurses_grouped_by_fulltimer
		Rails.cache.fetch([self, 'displayable_nurses_grouped_by_fulltimer']) {
			{
				'正社員' => nurses.displayable.full_timers.order_by_kana,
				'非正社員' => nurses.displayable.part_timers.order_by_kana
			}
		}
	end

	def cached_most_used_services_for_select
		Rails.cache.fetch([self, 'most_used_services_for_select']) { 
			top_6_titles_and_counts = self.services.without_nurse_id.includes(:appointments).group(:title).order(count: :desc).count(:appointments).first(6)
			service_title_and_id = self.services.without_nurse_id.order(:title).pluck(:title, :id)
			return_hash = {}
			return_hash['サービストップ6'] = top_6_titles_and_counts.map {|title, count| [title, service_title_and_id.find{|t,id| t == title}[1]] if service_title_and_id.find{|t,id| t == title}.present? }
			return_hash['その他'] = service_title_and_id - return_hash['サービストップ6']
			
			return_hash
		}
	end

	def cached_team_id_by_name
		Rails.cache.fetch([self, 'team_name_by_id']) {
			teams.pluck(:team_name, :id).to_h
		}
	end

	def self.cached_find(id)
		Rails.cache.fetch([name, id]) { find(id) }
	end

	def can_send_reminder_today?(date)
		if self.weekend_reminder_option == 0
			[1,2,3,4,5].include?(date.wday)
		elsif self.weekend_reminder_option == 1
			[1,2,3,4,5,6].include?(date.wday)
		elsif self.weekend_reminder_option == 2
			true
		end
	end

	def can_send_reminder_now?(datetime)
		parsed_reminder_hour = Time.parse(self.reminder_email_hour)
		valid_reminder_datetime = DateTime.new(datetime.year, datetime.month, datetime.day, parsed_reminder_hour.hour, parsed_reminder_hour.min, 0, '+9')
		datetime.between?((valid_reminder_datetime - 15.minutes), (valid_reminder_datetime + 15.minutes))
	end

	def monthly_service_counts_by_title_and_team(range_start, range_end)
		return_hash = {}

		start_date = range_start.to_date.beginning_of_day
		end_date = range_end.to_date.end_of_day

		titles = SalaryLineItem.where(planning_id: self.planning.id, service_date: start_date..end_date, archived_at: nil, cancelled: false).from_appointments.pluck(:title).uniq

		teams.each do |team|
			team_hash = {}

			nurse_ids = team.nurses.all.pluck(:id)

			team_salary_line_items = SalaryLineItem.includes(:appointment).from_appointments.where(nurse_id: nurse_ids, service_date: start_date..end_date, cancelled: false, archived_at: nil).where(appointments: {edit_requested: false}).group(:title).count
			team_salary_line_items_female = SalaryLineItem.includes(:patient, :appointment).from_appointments.where(nurse_id: nurse_ids, cancelled: false, service_date: start_date..end_date, archived_at: nil).where(patients: {gender: true}).where(appointments: {edit_requested: false}).group(:title).count
			team_salary_line_items_male = SalaryLineItem.includes(:patient, :appointment).from_appointments.where(nurse_id: nurse_ids, cancelled: false, service_date: start_date..end_date, archived_at: nil).where(patients: {gender: false}).where(appointments: {edit_requested: false}).group(:title).count

			titles.each do |title|
				team_hash[title] = {
					female: team_salary_line_items_female[title] || 0,
					male: team_salary_line_items_male[title] || 0,
					total: team_salary_line_items[title] || 0
				}
			end

			return_hash[team.team_name] = team_hash
		end

		return_hash
	end

	def service_counts_by_title_in_range(range_start, range_end)
		return_hash = {}
		corporation_hash = {}

		start_date = range_start.to_date.beginning_of_day
		end_date = range_end.to_date.end_of_day
		nurse_ids = self.nurses.displayable.ids
		salary_line_items = SalaryLineItem.includes(:appointment).where(nurse_id: nurse_ids, service_date: start_date..end_date, cancelled: false, archived_at: nil).from_appointments.where(appointments: {edit_requested: false}).group(:title).count
		salary_line_items_female = SalaryLineItem.includes(:patient, :appointment).where(nurse_id: nurse_ids, cancelled: false, service_date: start_date..end_date, archived_at: nil).from_appointments.where(patients: {gender: true}).where(appointments: {edit_requested: false}).group(:title).count
		salary_line_items_male = SalaryLineItem.includes(:patient, :appointment).where(nurse_id: nurse_ids, cancelled: false, service_date: start_date..end_date, archived_at: nil).from_appointments.where(patients: {gender: false}).where(appointments: {edit_requested: false}).group(:title).count

		
		titles = SalaryLineItem.where(nurse_id: nurse_ids, service_date: start_date..end_date, cancelled: false, archived_at: nil).from_appointments.pluck(:title).uniq

		titles.each do |title|
			corporation_hash[title] = {
				female: salary_line_items_female[title] || 0,
				male: salary_line_items_male[title] || 0,
				total: salary_line_items[title] || 0
			}
		end

		return_hash['全従業員'] = corporation_hash

		return_hash
	end

	def patients_with_contract_starting_after(date)
		patients.includes(:nurse).active.where('date_of_contract IS NOT NULL AND date_of_contract > ?', date).order(date_of_contract: :desc)
	end

	private


	def flush_cache 
		Rails.cache.delete([self.class.name, id])
	end

	def create_undefined_nurse
		self.nurses.create(name: "未定", displayable: false, kana: "あああああ")
	end

	def create_printing_option
		PrintingOption.create(corporation_id: self.id)
	end

end
