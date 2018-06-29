class UserPolicy < ApplicationPolicy

	def is_admin?
		user.admin == true
	end
end