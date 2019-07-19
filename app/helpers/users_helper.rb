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
		elsif user.role == 'schedule_restricted_with_salary_line_items'
			'全体.個別スケジュール　+　給与一部'
		elsif user.role == 'schedule_admin'
			'全体.個別.マスタースケジュール　+　給与一部'
		elsif user.role == 'corporation_admin'
			'全体.個別.マスタースケジュール　+　給与'
		end
	end

	def user_default_url_options(user)
		options = []
		planning = user.corporation.planning
		options << ['全従業員', planning_all_nurses_path(planning)]
		options << ['全利用者', planning_all_patients_path(planning)]
		options << ["#{user.nurse.try(:name)}個人シフト" ,planning_nurse_path(planning, user.nurse)] if user.nurse.present?
		options << ["#{user.nurse.team.try(:team_name)}チームシフト" ,planning_team_path(planning, user.nurse.team)] if user.nurse.present? && user.nurse.team.present?

		options
	end


end
