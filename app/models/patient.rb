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

	scope :order_by_kana, -> { order('kana COLLATE "C" ASC') }
	scope :active, -> { where(active: true) }

	def self.group_by_kana
		{
			'あ' => where( "kana LIKE 'あ%' OR kana LIKE 'い%'  OR kana LIKE 'う%' OR kana LIKE 'え%' OR kana LIKE 'お%'" ),
			'か' => where( "kana LIKE 'か%' OR kana LIKE 'き%'  OR kana LIKE 'く%' OR kana LIKE 'け%' OR kana LIKE 'こ%'" ),
			'さ' => where( "kana LIKE 'さ%' OR kana LIKE 'し%'  OR kana LIKE 'す%' OR kana LIKE 'せ%' OR kana LIKE 'そ%'" ),
			'た' => where( "kana LIKE 'た%' OR kana LIKE 'ち%'  OR kana LIKE 'つ%' OR kana LIKE 'て%' OR kana LIKE 'と%'" ),
			'な' => where( "kana LIKE 'な%' OR kana LIKE 'に%'  OR kana LIKE 'ぬ%' OR kana LIKE 'ね%' OR kana LIKE 'の%'" ),
			'は' => where( "kana LIKE 'は%' OR kana LIKE 'ひ%'  OR kana LIKE 'ふ%' OR kana LIKE 'へ%' OR kana LIKE 'ほ%'" ),
			'ま' => where( "kana LIKE 'ま%' OR kana LIKE 'み%'  OR kana LIKE 'む%' OR kana LIKE 'め%' OR kana LIKE 'も%'" ),
			'や' => where( "kana LIKE 'や%' OR kana LIKE 'ゆ%'  OR kana LIKE 'よ%'" ),
			'ら' => where( "kana LIKE 'ら%' OR kana LIKE 'り%'  OR kana LIKE 'る%' OR kana LIKE 'れ%' OR kana LIKE 'ろ%'" ),
			'わ' => where( "kana LIKE 'わ%' OR kana LIKE 'を%'  OR kana LIKE 'ん%'" ),
			'カナなし' => where(kana: [nil, ''])
		}
	end

end
