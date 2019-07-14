class Patient < ApplicationRecord
	acts_as_taggable
	acts_as_taggable_on :caveats

	belongs_to :corporation, touch: true
	belongs_to :nurse, optional: true
	belongs_to :care_manager, optional: true
	has_many :appointments
	has_many :recurring_appointments
	has_many :private_events
	has_many :provided_services
	has_many :patient_posts
	has_many :posts, through: :patient_posts
	
	validates :kana, presence: true, format: { with: /\A[\p{katakana}\p{blank}\0-9１-９}ー－]+\z/, message: 'フリガナはカタカナで入力してください' }
	validate :name_uniqueness

	before_save :save_previous_kaigo_level, if: :will_save_change_to_kaigo_level?
	
	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :active, -> { where(active: true) }
	scope :deactivated, -> { where(active: false) }
	scope :still_active_at, -> date { where('active IS TRUE OR (active IS FALSE AND end_of_contract > ?)', date) }
	scope :from_care_manager_corporation, -> id { where(care_manager_id: CareManager.where(care_manager_corporation_id: id).pluck(:id)) }

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

	def as_json
		{
			id: id, 
			title: name,
			is_nurse_resource: false 
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

	def provided_service_summary(date_range, options = {})
		inside_or_outside_insurance_scope = options[:within_insurance_scope] || false 
		
		array_of_service_summary = []
		provided_services_titles = ProvidedService.where(patient: self.id, archived_at: nil).from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).in_range(date_range).pluck(:title).uniq

        provided_services_titles.each do |title|
            service_type = Service.where(nurse_id: nil, title: title, corporation_id: self.corporation_id).first
			service_hash = {}
			
            if service_type.present? && service_type.invoiced_to_insurance? == inside_or_outside_insurance_scope
                provided_services = ProvidedService.where(patient: self.id, archived_at: nil, cancelled: false, title: title).from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).in_range(date_range).order(:appointment_start)
                service_hash[:title] = title
                service_hash[:official_title] = service_type.try(:official_title)
                service_hash[:service_code] = service_type.try(:service_code)
                service_hash[:unit_credits] = service_type.try(:unit_credit)
                if service_type.credit_calculation_method == 0
                    service_hash[:sum_total_credits] = provided_services.sum(:total_credits)
                elsif service_type.credit_calculation_method == 1
                    service_hash[:sum_total_credits] = service_type.try(:unit_credits)
                elsif service_type.credit_calculation_method == 2
                    service_hash[:sum_total_credits] = ((provided_services.first.service_date.to_date)..(date_range.last.to_date)).count * (service_type.try(:unit_credits) || 0)
				end
                service_hash[:sum_invoiced_total] = provided_services.sum(:invoiced_total)
                service_hash[:count] = service_type.credit_calculation_method == 2 ? ((provided_services.first.service_date.to_date)..(date_range.last.to_date)).count : provided_services.count

                array_of_service_summary << service_hash
            end
		end
		array_of_service_summary
	end

	def shifts_by_title_and_date_range(service_title, date_range)
		array_of_shifts = []

		shift_dates = ProvidedService.where(patient_id: self.id, title: service_title).from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).not_archived.in_range(date_range).pluck(:appointment_start, :appointment_end)
		shift_dates.map {|e| e[0] = e[0].strftime("%H:%M")}
		shift_dates.map {|e| e[1] = e[1].strftime("%H:%M")}
		shift_dates.uniq!
		shift_dates.sort! {|a,b| [a[0], a[1]] <=> [b[0], b[1]] }
			
		shift_dates.each do |start_and_end|
			shift_hash = {}
					
			shift_hash[:start_time] = start_and_end[0]
			shift_hash[:end_time] = start_and_end[1]
			recurring_appointments = RecurringAppointment.where(patient_id: self.id, title: service_title).where('starts_at::timestamp::time = ? AND ends_at::timestamp::time = ?', start_and_end[0], start_and_end[1]).not_terminated_at(date_range.first)
			shift_hash[:previsional] = recurring_appointments.map {|r| r.appointments(date_range.first, date_range.last).map(&:to_date) }.flatten
			shift_hash[:provided] = ProvidedService.from_appointments.includes(:appointment).where(appointments: {edit_requested: false}).where(title: service_title, patient_id: self.id, cancelled: false, archived_at: nil).in_range(date_range).where('appointment_start::timestamp::time = ? AND appointment_end::timestamp::time = ?', start_and_end[0], start_and_end[1]).pluck(:appointment_start).map(&:to_date)
	
			array_of_shifts << shift_hash
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
