class Corporation < ApplicationRecord
	has_many :users
	has_many :plannings

end
