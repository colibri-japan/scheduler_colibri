class Corporation < ApplicationRecord
	has_many :users
	has_many :plannings
	has_many :nurses

end
