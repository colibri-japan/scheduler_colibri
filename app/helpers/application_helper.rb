module ApplicationHelper

	def key_helper(key)
		if key == 'notice'
			'success'
		elsif key == 'alert'
			'warning'
		else
			key
		end
	end

	def weekday(date)
		unless date.nil?
			case date.wday
			when 1
				"(月)"
			when 2
				"(火)"
			when 3
				"(水)"
			when 4
				"(木)"
			when 5
				"(金)"
			when 6
				"(土)"
			when 0
				"(日)"
			else
				""
			end
		end
	end
end
