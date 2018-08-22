class Corporation < ApplicationRecord
	has_many :users
	has_many :plannings
	has_many :nurses
	has_many :patients

	after_create :create_undefined_nurse

	def self.add_undefined_nurse
		corporations = Corporation.all

		corporations.each do |corporation|
			corporation.nurses.create(name: "未定", displayable: false, kana: "あああああ")
		end
	end

	private

	def create_undefined_nurse
		self.nurses.create(name: "未定", displayable: false, kana: "あああああ")
	end

end
