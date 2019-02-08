class UserPolicy < ApplicationPolicy

	def is_admin?
		user.admin == true
	end

	def has_access_to_provided_services?
		user.schedule_restricted_with_provided_services? || user.schedule_admin? || user.corporation_admin?
	end

	def has_admin_access?
		user.schedule_admin? || user.corporation_admin?
	end

	def has_corporation_admin_role?
		user.corporation_admin?
	end
end