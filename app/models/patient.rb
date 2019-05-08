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
	has_many :posts
	
	validates :kana, presence: true, format: { with: /\A[\p{katakana}\p{blank}\0-9１-９}ー－]+\z/, message: 'フリガナはカタカナで入力してください' }
	validate :name_uniqueness
	
	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :active, -> { where(active: true) }
	scope :deactivated, -> { where(active: false) }
	scope :still_active_at, -> date { where('active IS TRUE OR (active IS FALSE AND end_of_contract > ?)', date) }

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

	private 
	
	def name_uniqueness 
		names = Patient.where(corporation_id: self.corporation_id, active: true).where.not(id: self.id).pluck(:name).map {|name| name.tr(' ','').tr('　','') }
		errors.add(:name, 'すでに同じ名前の利用者が登録されてます') if names.include? self.name.tr(' ','').tr('　','')
	end


end
