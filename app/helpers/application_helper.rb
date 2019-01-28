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

	def resource_creation_date(resource)
		if resource.created_at.in_time_zone('Tokyo').day == Time.current.in_time_zone('Tokyo').day
			resource.created_at.in_time_zone('Tokyo').strftime("今日 %H:%M")
		else
			resource.created_at.in_time_zone('Tokyo').strftime("%m月%d日 %H:%M")
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

	def weekday_full(date)
		unless date.nil? 
			case date.wday
			when 1
				"月曜日"
			when 2
				"火曜日"
			when 3
				"水曜日"
			when 4
				"木曜日"
			when 5
				"金曜日"
			when 6
				"土曜日"
			when 0
				"日曜日"
			else
				""
			end
		end
	end

	def frequency_to_text(recurring_appointment)
		if (0..10).include?(recurring_appointment.frequency)
            case recurring_appointment.frequency
            when 0
                "毎週"
			when 1
				"1，3，5週目"
			when 2
				"この日のみ"
			when 3
				"2，4週目"
			when 4
				"1週目"
			when 5
				"最後の週"
			when 6
				"最後の週以外毎週"
			when 7
				"隔週"
			when 8
				"2週目"
			when 9
				"3週目"
			when 10
				"4週目"
			else
				""
			end
        end
    end



end
