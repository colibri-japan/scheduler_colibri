class ServicePolicy < ApplicationPolicy
	
	def same_corporation_as_current_user?
		record.corporation_id == user.corporation_id
	end

end