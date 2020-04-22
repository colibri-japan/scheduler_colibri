
class Patient < ApplicationRecord
	acts_as_taggable
	acts_as_taggable_on :caveats

	belongs_to :corporation, touch: true
	belongs_to :team, optional: true
	belongs_to :nurse, optional: true
	has_many :care_plans
	has_many :care_managers, through: :care_plans
	belongs_to :second_care_manager, optional: true, class_name: 'CareManager'
	has_many :appointments
	has_many :recurring_appointments
	has_many :private_events
	has_many :salary_line_items
	has_many :patient_posts
	has_many :posts, through: :patient_posts

	accepts_nested_attributes_for :care_plans
	
	validates :kana, presence: true, format: { with: /\A[\p{katakana}\p{blank}\0-9１-９}ー－]+\z/, message: 'フリガナはカタカナで入力してください' }
	validate :name_uniqueness

	before_save :save_previous_kaigo_level, if: :will_save_change_to_kaigo_level?
	
	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :active, -> { where(active: true) }
	scope :deactivated, -> { where(active: false) }
	scope :still_active_at, -> date { where('active IS TRUE OR (active IS FALSE AND end_of_contract > ?)', date) }
	scope :from_care_manager_corporation, -> id { where(care_manager_id: CareManager.where(care_manager_corporation_id: id).pluck(:id)) }
	scope :male, -> { where(gender: false) }
	scope :female, -> { where(gender: true) }
	scope :with_care_plan_valid_at, -> date { includes(:care_plans).where('care_plans.kaigo_certification_validity_start <= ? AND care_plans.kaigo_certification_validity_end >= ?', date, date) }

	def age
		if birthday.present?
			now = Time.current.in_time_zone('Tokyo')
			now.year - birthday.year - (now.month > birthday.month || (now.month == birthday.month && now.day >= birthday.day) ? 0 : 1)
		else
			''
		end
	end

	def public_assistance_ratio_1
		if public_assistance_id_1.present? && public_assistance_id_1.size > 2
			case public_assistance_id_1[0..1]
			when '12'
				#社会保護
				1
			when '56'
				#特定対策
				0.97
			when '57'
				#特定対策
				0.97
			when '51'
				#治療研究の係る医療の給付
				1
			when '19'
				#原子爆弾被爆者
				1
			when '15'
				#身体障害者福祉法「更生医療」
				1
			when '21'
				#精神保健.精神障害者福祉士に関する法律「通院医療」
				0.95
			when '11'
				#結核予防法「従業禁止、命令入所者の医療」
				1
			when '10'
				#結核予防法「一般患者に対する医療」
				0.95
			else
				0
			end
		else
			0
		end
	end

	def public_assistance_ratio_2
		if public_assistance_id_2.present? && public_assistance_id_2.size > 2
			case public_assistance_id_2[0..1]
			when '12'
				1
			when '56'
				0.97
			when '57'
				0.97
			when '51'
				1
			when '19'
				1
			when '15'
				1
			when '21'
				0.95
			when '11'
				1
			when '10'
				0.95
			else
				0
			end
		else
			0
		end
	end

	def net_invoicing_ratio
		if ratio_paid_by_patient.present?
			if public_assistance_ratio_1 > 0 || public_assistance_ratio_2 > 0
				(1 - [public_assistance_ratio_1, public_assistance_ratio_2].max).round(2)
			else
				ratio_paid_by_patient.to_f / 10
			end
		else
			1
		end
	end

	def self.group_by_kana
		{
			'あ' => where( "kana LIKE 'あ%' OR kana LIKE 'い%'  OR kana LIKE 'う%' OR kana LIKE 'え%' OR kana LIKE 'お%' OR kana LIKE 'ア%' OR kana LIKE 'イ%'  OR kana LIKE 'ウ%' OR kana LIKE 'エ%' OR kana LIKE 'オ%'" ).order_by_kana,
			'か' => where( "kana LIKE 'か%' OR kana LIKE 'き%'  OR kana LIKE 'く%' OR kana LIKE 'け%' OR kana LIKE 'こ%' OR kana LIKE 'カ%' OR kana LIKE 'キ%'  OR kana LIKE 'ク%' OR kana LIKE 'ケ%' OR kana LIKE 'コ%' OR kana LIKE 'が%' OR kana LIKE 'ぎ%'  OR kana LIKE 'ぐ%' OR kana LIKE 'げ%' OR kana LIKE 'ご%' OR kana LIKE 'ガ%' OR kana LIKE 'ギ%'  OR kana LIKE 'グ%' OR kana LIKE 'ゲ%' OR kana LIKE 'ゴ%'" ).order_by_kana,
			'さ' => where( "kana LIKE 'さ%' OR kana LIKE 'し%'  OR kana LIKE 'す%' OR kana LIKE 'せ%' OR kana LIKE 'そ%' OR kana LIKE 'サ%' OR kana LIKE 'シ%'  OR kana LIKE 'ス%' OR kana LIKE 'セ%' OR kana LIKE 'ソ%' OR kana LIKE 'ざ%' OR kana LIKE 'じ%'  OR kana LIKE 'ず%' OR kana LIKE 'ぜ%' OR kana LIKE 'ぞ%' OR kana LIKE 'ザ%' OR kana LIKE 'ジ%'  OR kana LIKE 'ズ%' OR kana LIKE 'ゼ%' OR kana LIKE 'ゾ%'" ).order_by_kana,
			'た' => where( "kana LIKE 'た%' OR kana LIKE 'ち%'  OR kana LIKE 'つ%' OR kana LIKE 'て%' OR kana LIKE 'と%' OR kana LIKE 'タ%' OR kana LIKE 'チ%'  OR kana LIKE 'ツ%' OR kana LIKE 'テ%' OR kana LIKE 'ト%' OR kana LIKE 'だ%' OR kana LIKE 'ぢ%'  OR kana LIKE 'づ%' OR kana LIKE 'で%' OR kana LIKE 'ど%' OR kana LIKE 'ダ%' OR kana LIKE 'ヂ%'  OR kana LIKE 'ヅ%' OR kana LIKE 'デ%' OR kana LIKE 'ド%'" ).order_by_kana,
			'な' => where( "kana LIKE 'な%' OR kana LIKE 'に%'  OR kana LIKE 'ぬ%' OR kana LIKE 'ね%' OR kana LIKE 'の%' OR kana LIKE 'ナ%' OR kana LIKE 'ニ%'  OR kana LIKE 'ヌ%' OR kana LIKE 'ネ%' OR kana LIKE 'ノ%'" ).order_by_kana,
			'は' => where( "kana LIKE 'は%' OR kana LIKE 'ひ%'  OR kana LIKE 'ふ%' OR kana LIKE 'へ%' OR kana LIKE 'ほ%' OR kana LIKE 'ハ%' OR kana LIKE 'ヒ%'  OR kana LIKE 'フ%' OR kana LIKE 'ヘ%' OR kana LIKE 'ホ%' OR kana LIKE 'ば%' OR kana LIKE 'び%'  OR kana LIKE 'ぶ%' OR kana LIKE 'べ%' OR kana LIKE 'ぼ%' OR kana LIKE 'ぱ%' OR kana LIKE 'ぴ%'  OR kana LIKE 'ぷ%' OR kana LIKE 'ぺ%' OR kana LIKE 'ぽ%'  OR kana LIKE 'バ%' OR kana LIKE 'ビ%'  OR kana LIKE 'ブ%' OR kana LIKE 'ベ%' OR kana LIKE 'ボ%' OR kana LIKE 'パ%' OR kana LIKE 'ピ%'  OR kana LIKE 'プ%' OR kana LIKE 'ペ%' OR kana LIKE 'ポ%'" ).order_by_kana,
			'ま' => where( "kana LIKE 'ま%' OR kana LIKE 'み%'  OR kana LIKE 'む%' OR kana LIKE 'め%' OR kana LIKE 'も%' OR kana LIKE 'マ%' OR kana LIKE 'ミ%'  OR kana LIKE 'ム%' OR kana LIKE 'メ%' OR kana LIKE 'モ%'" ).order_by_kana,
			'や' => where( "kana LIKE 'や%' OR kana LIKE 'ゆ%'  OR kana LIKE 'よ%' OR kana LIKE 'ヤ%' OR kana LIKE 'ユ%' OR kana LIKE 'ヨ%'" ).order_by_kana,
			'ら' => where( "kana LIKE 'ら%' OR kana LIKE 'り%'  OR kana LIKE 'る%' OR kana LIKE 'れ%' OR kana LIKE 'ろ%' OR kana LIKE 'ラ%' OR kana LIKE 'リ%'  OR kana LIKE 'ル%' OR kana LIKE 'レ%' OR kana LIKE 'ロ%'" ).order_by_kana,
			'わ' => where( "kana LIKE 'わ%' OR kana LIKE 'を%'  OR kana LIKE 'ん%' OR kana LIKE 'ワ%' OR kana LIKE 'ヲ%' OR kana LIKE 'ン%'" ).order_by_kana,
			'カナなし' => where(kana: [nil, ''])
		}
	end

	def kana_group
		return 'カナなし' if kana.nil?

		case kana[0]
		when 'あ','い','う','え','お','ア','イ','ウ','エ','オ'
			'あ'
		when 'か','き','く','け','こ','カ','キ','ク','ケ','コ', 'が','ぎ','ぐ','げ','ご','ガ','ギ','グ','ゲ','ゴ'
			'か'
		when 'さ','し','す','せ','そ','サ','シ','ス','セ','ソ', 'ざ','じ','ず','ぜ','ぞ','ザ','ジ','ズ','ゼ','ゾ'
			'さ'
		when 'た','ち','つ','て','と','タ','チ','ツ','テ','ト','だ','ぢ','づ','で','ど','ダ','ヂ','ヅ','デ','ド'
			'た'
		when 'な','に','ぬ','ね','の','ナ','ニ','ヌ','ネ','ノ'
			'な'
		when 'は','ひ','ふ','へ','ほ','ハ','ヒ','フ','ヘ','ホ', 'ば','び','ぶ','べ','ぼ','バ','ビ','ブ','ベ','ボ'
			'は'
		when 'ま','み','む','め','も','マ','ミ','ム','メ','モ'
			'ま'
		when 'や','ゆ','よ','ヤ','ユ','ヨ'
			'や'
		when 'ら','り','る','れ','ろ','ラ','リ','ル','レ','ロ'
			'ら'
		when 'わ','を','ん','ワ','ヲ','ン'
			'わ'
		else
			'カナなし'
		end
	end

	def as_json
		{
			id: "patient_#{id}", 
			title: name,
			model_name: 'patient',
			record_id: id
		}
	end

	def current_kaigo_level
		if self.kaigo_certification_validity_start.present? && (Date.today.beginning_of_month..Date.today.end_of_month).include?(self.kaigo_certification_validity_start)
			(kaigo_level || 0) >= (self.previous_kaigo_level || 0) ? self.kaigo_level : self.previous_kaigo_level
		else
			kaigo_level
		end
	end

	def current_max_credits
		case current_kaigo_level
		when 0
			5003
		when 1
			10473
		when 2
			16692
		when 3
			19616
		when 4
			26931
		when 5
			30806
		when 6
			36065
		else
			9999999
		end
	end

	def invoicing_summary(date_range, options = {})
		summary_hash = {inside_insurance_scope: {}, outside_insurance_scope: [], summary_data: {}}
		inside_insurance_scope_hash = {}
		appointments_grouped_by_service = self.appointments.operational.in_range(date_range).includes(:service).group(:service_id).select('service_id, sum(total_invoiced) as sum_total_invoiced, sum(total_wage) as sum_total_wage, sum(total_credits) as sum_total_credits, count(*) as total_count, min(starts_at) as minimum_starts_at, max(ends_at) as maximum_ends_at')
		cancelled_but_invoiceable_appointments = self.appointments.includes(:service).not_archived.edit_not_requested.where(cancelled: true).in_range(date_range).where.not(total_invoiced: [nil, 0])
		services_inside_insurance_scope = []
		services_outside_insurance_scope = []

		appointments_grouped_by_service.each do |appointment_group|
			service = appointment_group.try(:service)
			if service.present?
				service_hash = {}
				service_hash[:title] = service.try(:title)
				service_hash[:insurance_service_category] = service.try(:insurance_service_category)
				service_hash[:official_title] = service.try(:official_title)
				service_hash[:service_code] = service.try(:service_code)
				service_hash[:unit_credits] = service.try(:unit_credits)
				service_hash[:invoiced_to_insurance] = service.invoiced_to_insurance?
				service_hash[:calculation_method] = service.credit_calculation_method
				case service.credit_calculation_method
				when 0
					sum_total_credits = (appointment_group.total_count || 0) * (service.try(:unit_credits) || 0)
				when 1
					sum_total_credits = service.try(:unit_credits)
				when 2
					if self.date_of_contract.present? && self.date_of_contract.month == date_range.first.month 
						day_count = (date_of_contract..date_range.last).count
					elsif self.end_of_contract.present? && self.end_of_contract.month == date_range.last.month 
						day_count = (date_range.first..end_of_contract).count
					else
						day_count = 0
					end
					sum_total_credits = day_count * (service.try(:unit_credits) || 0)
				else
					sum_total_credits = 0
				end
				service_hash[:sum_total_credits] = sum_total_credits
				service_hash[:sum_total_invoiced] = service.inside_insurance_scope? ? (sum_total_credits * corporation.credits_to_jpy_ratio).floor : appointment_group.sum_total_invoiced
				service_hash[:count] = service.credit_calculation_method == 2 ? day_count : appointment_group.total_count

				if service.invoiced_to_insurance?
					services_inside_insurance_scope << service_hash
				else
					services_outside_insurance_scope << service_hash
				end
			end
		end

		services_outside_insurance_scope.each do |service_hash|
			service_shift_hash = {service_hash: {}, shifts_hash: {}}
			service_shift_hash[:service_hash] = service_hash 
			service_shift_hash[:shifts_hash] = self.shifts_by_title_and_date_range(service_hash[:title], date_range)
			summary_hash[:outside_insurance_scope] << service_shift_hash
		end

		cancelled_but_invoiceable_appointments.each do |cancelled_appointment|
			service = cancelled_appointment.service
			if service.present?
				service_shift_hash = {service_hash: {}, shifts_hash: {}}
				service_shift_hash[:service_hash] = {
					title: "#{service.title} (#{cancelled_appointment.starts_at.strftime('%-d日')}キャンセル)",
					official_title: service.official_title,
					service_code: service.service_code,
					insurance_service_category: service.insurance_service_category,
					unit_credits: service.unit_credits,
					invoiced_to_insurance: false,
					sum_total_credits: 0,
					sum_total_invoiced: cancelled_appointment.total_invoiced,
					count: 1
				}
				service_shift_hash[:shifts_hash] = [{
					start_time: cancelled_appointment.starts_at.strftime("%H:%M"),
					end_time: cancelled_appointment.ends_at.strftime("%H:%M"),
					previsional: [],
					provided: [cancelled_appointment.starts_at.to_date]
				}]
				summary_hash[:outside_insurance_scope] << service_shift_hash
			end
		end

		services_inside_insurance_scope.group_by {|service_hash| service_hash[:insurance_service_category] }.each do |category_id, service_hashes|
			category_sub_total_credits = service_hashes.sum {|service_hash| service_hash[:sum_total_credits] || 0 }
			category_bonus_credits = ([11,102].include?(category_id.to_i) && corporation.invoicing_bonus_ratio.present?) ? (category_sub_total_credits * ((corporation.invoicing_bonus_ratio || 1) - 1)).round : 0
			category_second_bonus_credits = ([11,102].include?(category_id.to_i) && corporation.invoicing_bonus_ratio!= 1) ? (category_sub_total_credits * ((corporation.second_invoicing_bonus_ratio || 1) - 1)).round : 0
			category_summary = {
				insurance_category_id: category_id,
				category_sub_total_credits: category_sub_total_credits,
				category_bonus_credits: category_bonus_credits,
				category_second_bonus_credits: category_second_bonus_credits,
				category_total_credits: category_sub_total_credits + category_bonus_credits + category_second_bonus_credits
			}
			array_of_service_and_shifts_hashed = []
			service_hashes.each do |service_hash|
				service_shift_hash = {service_hash: {}, shifts_hash: {}}
				service_shift_hash[:service_hash] = service_hash
				service_shift_hash[:shifts_hash] = self.shifts_by_title_and_date_range(service_hash[:title], date_range)   
				array_of_service_and_shifts_hashed << service_shift_hash
			end
			inside_insurance_scope_hash[category_summary] = array_of_service_and_shifts_hashed
		end

		summary_hash[:inside_insurance_scope] = inside_insurance_scope_hash 

		total_credits = summary_hash[:inside_insurance_scope].sum {|category_summary, services_hashes| category_summary[:category_sub_total_credits] || 0 }
		total_bonus_credits = summary_hash[:inside_insurance_scope].sum {|category_summary, services_hashes| (category_summary[:category_bonus_credits] || 0) + (category_summary[:category_second_bonus_credits] || 0 ) }
		total_credits_with_bonus = summary_hash[:inside_insurance_scope].sum {|category_summary, services_hashes| category_summary[:category_total_credits] || 0 }
		credits_within_max_budget = total_credits > current_max_credits ? current_max_credits : total_credits
		credits_with_bonus_within_max_budget = total_credits_with_bonus > current_max_credits ? current_max_credits : total_credits_with_bonus
		total_invoiced = (total_credits_with_bonus * corporation.credits_to_jpy_ratio).floor
		total_invoiced_inside_insurance_scope = (credits_with_bonus_within_max_budget * corporation.credits_to_jpy_ratio).floor
		amount_paid_by_insurance = (total_invoiced_inside_insurance_scope * (10 - (ratio_paid_by_patient || 0)) / 10).floor
		amount_in_excess_from_insurance_paid_by_patient = total_invoiced - total_invoiced_inside_insurance_scope
		total_paid_by_patient_from_insurance_without_assistance = total_invoiced - amount_paid_by_insurance
		public_assistance_1 =  public_assistance_ratio_1 > 0 ? (total_invoiced_inside_insurance_scope * public_assistance_ratio_1).floor - amount_paid_by_insurance : 0
		public_assistance_2 = public_assistance_ratio_1 > 0 && public_assistance_ratio_2 > 0 && public_assistance_ratio_2 > public_assistance_ratio_1 ? (total_invoiced_inside_insurance_scope * public_assistance_ratio_2).floor - amount_paid_by_insurance - public_assistance_1 : 0
		total_paid_by_patient_from_insurance = total_invoiced_inside_insurance_scope - amount_paid_by_insurance - public_assistance_1 - public_assistance_2
		amount_paid_by_patient_outside_insurance = summary_hash[:outside_insurance_scope].sum {|service_shifts_hash| service_shifts_hash[:service_hash][:sum_total_invoiced] || 0 }
		summary_hash[:summary_data] = {
			total_credits: total_credits,
			total_bonus_credits: total_bonus_credits,
			total_credits_with_bonus: total_credits_with_bonus,
			credits_within_max_budget: credits_within_max_budget,
			credits_with_bonus_within_max_budget: credits_with_bonus_within_max_budget,
			credits_exceeding_max_budget: total_credits_with_bonus - credits_within_max_budget,
			credits_with_bonus_exceeding_max_budget: total_credits_with_bonus - credits_with_bonus_within_max_budget,
			total_invoiced: total_invoiced,
			amount_paid_by_insurance: amount_paid_by_insurance,
			total_invoiced_inside_insurance_scope: total_invoiced_inside_insurance_scope,
			amount_within_insurance_paid_by_patient: total_invoiced_inside_insurance_scope - amount_paid_by_insurance,
			amount_in_excess_from_insurance_paid_by_patient: amount_in_excess_from_insurance_paid_by_patient,
			total_paid_by_patient_from_insurance_without_assistance: total_paid_by_patient_from_insurance_without_assistance,
			amount_paid_by_public_assistance_1: public_assistance_1,
			amount_paid_by_public_assistance_2: public_assistance_2,
			total_paid_by_patient_from_insurance: total_paid_by_patient_from_insurance,
			amount_paid_by_patient_outside_insurance: amount_paid_by_patient_outside_insurance,
			final_amount_paid_by_patient: total_paid_by_patient_from_insurance + amount_in_excess_from_insurance_paid_by_patient + amount_paid_by_patient_outside_insurance
		}

		summary_hash
	end

	def shifts_by_title_and_date_range(service_title, date_range)
		array_of_shifts = []

		shift_dates = self.appointments.where(title: service_title).in_range(date_range).pluck(:starts_at, :ends_at)
		shift_dates.map {|e| e[0] = e[0].strftime("%H:%M")}
		shift_dates.map {|e| e[1] = e[1].strftime("%H:%M")}
		shift_dates.uniq!
		shift_dates.sort! {|a,b| [a[0], a[1]] <=> [b[0], b[1]] }
			
		shift_dates.each do |start_and_end|
			shift_hash = {}
					
			shift_hash[:start_time] = start_and_end[0]
			shift_hash[:end_time] = start_and_end[1]
			shift_hash[:previsional] = self.recurring_appointments.where(title: service_title).where('starts_at::timestamp::time = ? AND ends_at::timestamp::time = ?', start_and_end[0], start_and_end[1]).not_terminated_at(date_range.first).map {|r| r.appointments(date_range.first, date_range.last).map(&:to_date)}.flatten
			shift_hash[:provided] = self.appointments.where(title: service_title).operational.in_range(date_range).where('appointments.starts_at::timestamp::time = ? AND appointments.ends_at::timestamp::time = ?', start_and_end[0], start_and_end[1]).pluck(:starts_at).map(&:to_date)
	
			array_of_shifts << shift_hash unless shift_hash[:previsional].blank? && shift_hash[:provided].blank?
		end
		
    	array_of_shifts
	end

	private 

	def save_previous_kaigo_level
		self.previous_kaigo_level = self.kaigo_level_was
	end
	
	def name_uniqueness 
		names = Patient.where(corporation_id: self.corporation_id, active: true).where.not(id: self.id).pluck(:name).map {|name| name.tr(' ','').tr('　','') }
		errors.add(:name, 'すでに同じ名前の利用者が登録されてます') if names.include? self.name.tr(' ','').tr('　','')
	end


end
