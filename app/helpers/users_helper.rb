module UsersHelper

	def user_admin(user)
		if user.admin == true
			"アドミン"
		else
			"ユーザー"
		end
	end

	def user_role(user)
		if user.role == 'schedule_restricted'
			'全体.個別スケジュールのみ'
		elsif user.role == 'schedule_admin'
			'スケジュール全権限'
		elsif user.role == 'corporation_admin'
			'スケジュール全権限 +　給与詳細'
		end
	end


end
