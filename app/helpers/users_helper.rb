module UsersHelper

	def user_admin(user)
		if user.admin == true
			"アドミン"
		else
			"ユーザー"
		end
	end


end
