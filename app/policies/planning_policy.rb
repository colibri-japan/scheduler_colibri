class PlanningPolicy < ApplicationPolicy
	
	def same_corporation_as_current_user?
		record.corporation_id == user.corporation_id
	end

	def is_not_archived?
		record.archived != true
	end
end