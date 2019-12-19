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

	enum business_vertical: {
		elderly_care_and_nursing: 0,
		temporary_staffing: 1
	}

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
			return nurses.displayable.not_archived.order_by_kana.group_by {|n| team_name_by_id[n.team_id] || 'チーム所属なし' }
		}
	end

	def cached_nurses_grouped_by_fulltimer_for_select
		Rails.cache.fetch([self, 'nurses_grouped_by_fulltimer_for_select']) {
			{
				'正社員' => nurses.not_archived.full_timers.order_by_kana.pluck(:name, :id),
				'非正社員' => nurses.not_archived.part_timers.order_by_kana.pluck(:name, :id)
			}
		}
	end

	def cached_displayable_nurses_grouped_by_fulltimer_for_select
		Rails.cache.fetch([self, 'displayable_nurses_grouped_by_fulltimer_for_select']) {
			{
				'正社員' => nurses.displayable.not_archived.full_timers.order_by_kana.pluck(:name, :id),
				'非正社員' => nurses.displayable.not_archived.part_timers.order_by_kana.pluck(:name, :id)
			}
		}
	end

	def cached_displayable_nurses_grouped_by_fulltimer
		Rails.cache.fetch([self, 'displayable_nurses_grouped_by_fulltimer']) {
			{
				'正社員' => nurses.displayable.not_archived.full_timers.order_by_kana,
				'非正社員' => nurses.displayable.not_archived.part_timers.order_by_kana
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

	def appointments_count_by_title_and_team_in_range(range_start, range_end)
		return_hash = {}

		start_date = range_start.to_date.beginning_of_day
		end_date = range_end.to_date.end_of_day

		titles = self.planning.appointments.in_range(start_date..end_date).operational.pluck(:title).uniq

		if self.teams.present?
			teams.each do |team|
				team_hash = {}
				nurse_ids = team.nurses.not_archived.pluck(:id)
	
				team_salary_line_items = self.planning.appointments.in_range(start_date..end_date).operational.where(nurse_id: nurse_ids).group(:title).count
				team_salary_line_items_female = self.planning.appointments.joins(:patient).in_range(start_date..end_date).operational.where(nurse_id: nurse_ids).where(patients: {gender: true}).group(:title).count
				team_salary_line_items_male = self.planning.appointments.joins(:patient).in_range(start_date..end_date).operational.where(nurse_id: nurse_ids).where(patients: {gender: false}).group(:title).count
	
				titles.each do |title|
					team_hash[title] = {
						female: team_salary_line_items_female[title] || 0,
						male: team_salary_line_items_male[title] || 0,
						total: team_salary_line_items[title] || 0
					}
				end
	
				return_hash[team.team_name] = team_hash
			end
		else
			corporation_hash = {}
			salary_line_items = self.planning.appointments.in_range(starts_date..end_date).operational.group(:title).count
			salary_line_items_female = self.planning.appointments.joins(:patient).where(patients: {gender: true}).in_range(starts_date..end_date).operational.group(:title).count
			salary_line_items_male = self.planning.appointments.joins(:patient).where(patients: {gender: false}).in_range(starts_date..end_date).operational.group(:title).count
			
			titles.each do |title|
				corporation_hash[title] = {
					female: salary_line_items_female[title] || 0,
					male: salary_line_items_male[title]|| 0,
					total: salary_line_items[title] || 0
				}
			end

			return_hash['全従業員'] = corporation_hash
		end 

		return_hash
	end

	def patients_with_contract_starting_after(date)
		patients.includes(:nurse).active.where('date_of_contract IS NOT NULL AND date_of_contract > ?', date).order(date_of_contract: :desc)
	end

	def revenue_per_team(range)
		return_hash = {}

		self.teams.each do |team|
			revenue_from_insurance = self.planning.appointments.operational.in_range(range).joins(:service).where(nurse_id: team.nurses.pluck(:id)).where(services: {inside_insurance_scope: true}).sum('appointments.total_credits') || 0
			revenue_from_insurance = revenue_from_insurance * (self.invoicing_bonus_ratio || 1) * (self.credits_to_jpy_ratio || 0)
			revenue_outside_insurance = self.planning.appointments.edit_not_requested.not_archived.in_range(range).joins(:service).where(nurse_id: team.nurses.pluck(:id)).where(services: {inside_insurance_scope: false}).sum('appointments.total_invoiced') || 0
			return_hash[team.team_name] = (revenue_from_insurance + revenue_outside_insurance).floor
		end

		return_hash = return_hash.sort_by { |a,b| b }.reverse 

		return_hash
	end

	def salary_per_team(range)
		return_hash = {}

		self.teams.each do |team|
			salary_from_appointments = self.planning.appointments.edit_not_requested.not_archived.in_range(range).where(nurse_id: team.nurses.displayable.part_timers.ids).sum('appointments.total_wage') || 0
			salary_from_line_items = self.planning.salary_line_items.in_range(range).where(nurse_id: team.nurses.displayable.ids).not_from_appointments.sum(:total_wage) || 0
			salary_from_wage = team.nurses.displayable.full_timers.sum(:monthly_wage) || 0
			return_hash[team.team_name] = salary_from_appointments + salary_from_line_items + salary_from_wage
		end

		return_hash
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
