module PlanningsHelper

	def title(planning)
		planning.title.present? ? "#{planning.title} (#{planning.business_month}月)" : "#{planning.business_month}月のスケジュール"
	end
end
