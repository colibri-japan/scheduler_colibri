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
			'あ' => where( "kana LIKE 'あ%' OR kana LIKE 'い%'  OR kana LIKE 'う%' OR kana LIKE 'え%' OR kana LIKE 'お%' OR kana LIKE 'ア%' OR kana LIKE 'イ%'  OR kana LIKE 'ウ%' OR kana LIKE 'エ%' OR kana LIKE 'オ%'" ),
			'か' => where( "kana LIKE 'か%' OR kana LIKE 'き%'  OR kana LIKE 'く%' OR kana LIKE 'け%' OR kana LIKE 'こ%' OR kana LIKE 'カ%' OR kana LIKE 'キ%'  OR kana LIKE 'ク%' OR kana LIKE 'ケ%' OR kana LIKE 'コ%'" ),
			'さ' => where( "kana LIKE 'さ%' OR kana LIKE 'し%'  OR kana LIKE 'す%' OR kana LIKE 'せ%' OR kana LIKE 'そ%' OR kana LIKE 'サ%' OR kana LIKE 'シ%'  OR kana LIKE 'ス%' OR kana LIKE 'セ%' OR kana LIKE 'ソ%'" ),
			'た' => where( "kana LIKE 'た%' OR kana LIKE 'ち%'  OR kana LIKE 'つ%' OR kana LIKE 'て%' OR kana LIKE 'と%' OR kana LIKE 'タ%' OR kana LIKE 'チ%'  OR kana LIKE 'ツ%' OR kana LIKE 'テ%' OR kana LIKE 'ト%'" ),
			'な' => where( "kana LIKE 'な%' OR kana LIKE 'に%'  OR kana LIKE 'ぬ%' OR kana LIKE 'ね%' OR kana LIKE 'の%' OR kana LIKE 'ナ%' OR kana LIKE 'ニ%'  OR kana LIKE 'ヌ%' OR kana LIKE 'ネ%' OR kana LIKE 'ノ%'" ),
			'は' => where( "kana LIKE 'は%' OR kana LIKE 'ひ%'  OR kana LIKE 'ふ%' OR kana LIKE 'へ%' OR kana LIKE 'ほ%' OR kana LIKE 'ハ%' OR kana LIKE 'ヒ%'  OR kana LIKE 'フ%' OR kana LIKE 'ヘ%' OR kana LIKE 'ホ%'" ),
			'ま' => where( "kana LIKE 'ま%' OR kana LIKE 'み%'  OR kana LIKE 'む%' OR kana LIKE 'め%' OR kana LIKE 'も%' OR kana LIKE 'マ%' OR kana LIKE 'ミ%'  OR kana LIKE 'ム%' OR kana LIKE 'メ%' OR kana LIKE 'モ%'" ),
			'や' => where( "kana LIKE 'や%' OR kana LIKE 'ゆ%'  OR kana LIKE 'よ%' OR kana LIKE 'ヤ%' OR kana LIKE 'ユ%' OR kana LIKE 'ヨ%'" ),
			'ら' => where( "kana LIKE 'ら%' OR kana LIKE 'り%'  OR kana LIKE 'る%' OR kana LIKE 'れ%' OR kana LIKE 'ろ%' OR kana LIKE 'ラ%' OR kana LIKE 'リ%'  OR kana LIKE 'ル%' OR kana LIKE 'レ%' OR kana LIKE 'ロ%'" ),
			'わ' => where( "kana LIKE 'わ%' OR kana LIKE 'を%'  OR kana LIKE 'ん%' OR kana LIKE 'ワ%' OR kana LIKE 'オ%' OR kana LIKE 'ン%'" ),
			'カナなし' => where(kana: [nil, ''])
		}
	end

end
