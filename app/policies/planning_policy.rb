class PlanningPolicy < ApplicationPolicy

	def is_employee?
		record.corporation_id == user.corporation_id
	end
end