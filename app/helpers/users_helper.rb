module UsersHelper

	def user_admin(user)
		if user.admin == true
			"アドミン"
		else
			"ユーザー"
		end
	end

	def user_role(user)
		case user.role 
		when 'nurse_restricted'
			'現場従業員（個人シフトのみ）'
		when 'schedule_readonly'
			'シフト閲覧のみ'
		when 'schedule_restricted'
			'全体.個別スケジュール'
		when 'schedule_restricted_with_salary_line_items'
			'全体.個別スケジュール　+　給与一部'
		when 'schedule_admin'
			'全体.個別.マスタースケジュール　+　給与一部'
		when 'corporation_admin'
			'全体.個別.マスタースケジュール　+　給与'
		else
			''
		end
	end

	def user_default_calendar_options(user)
		options = []
		planning = user.corporation.planning
		options << ['全従業員', 0]
		options << ['全利用者', 1]
		options << ["個人シフト" , 2] if user.nurse.present?
		options << ["#{user.nurse.team.team_name}チームシフト" , 3] if user.nurse.present? && user.nurse.team.present?

		options
	end


end
