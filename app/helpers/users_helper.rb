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
			'全体.個別スケジュール'
		elsif user.role == 'schedule_restricted_with_provided_services'
			'全体.個別スケジュール　+　給与一部'
		elsif user.role == 'schedule_admin'
			'全体.個別.マスタースケジュール　+　給与一部'
		elsif user.role == 'corporation_admin'
			'全体.個別.マスタースケジュール　+　給与'
		end
	end


end
