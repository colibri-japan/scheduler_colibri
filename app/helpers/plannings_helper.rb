module PlanningsHelper

	def title(planning)
		planning.title.present? ? "#{planning.title} (#{planning.business_month}月)" : "#{planning.business_month}月のスケジュール"
	end

	def insurance_category(boolean)
		boolean ? '医療' : '介護'
	end

	def kaigo_level(kaigo_level)
		case kaigo_level 
		when 0 
			'要支援1'
		when 1
			'要支援2'
		when 2 
			'要介護1'
		when 3 
			'要介護2'
		when 4
			'要介護3'
		when 5
			'要介護4'
		when 6
			'要介護5'
		else 
			''
		end
	end

	def japanese_date_if_present(date)
		date.present? ? date.strftime('%Y年%-m月%-d日') : '未記入'
	end
end
