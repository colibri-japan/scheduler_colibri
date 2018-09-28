class PlanningPolicy < ApplicationPolicy

	def is_employee?
		record.corporation_id == user.corporation_id
	end

	def is_not_archived?
		record.archived != true
	end
end