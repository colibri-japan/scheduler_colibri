module ApplicationHelper

	def title(text)
		content_for :title, text
	end
	
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

	WAREKI_ERA = [['明治', '明治'],['大正', '大正'],['昭和', '昭和'],['平成','平成'],['令和','令和']].freeze
	WAREKI_ERA_SHORT = [['平成','平成'],['令和','令和']].freeze


	def wareki_era
		[['明治', '明治'],['大正', '大正'],['昭和', '昭和'],['平成','平成'],['令和','令和']]
	end

	WAREKI_YEARS = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6,6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23],[24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31], [32, 32], [33, 33], [34, 34], [35, 35], [36, 36], [37, 37], [38, 38], [39, 39], [40, 40], [41, 41], [42, 42], [43, 43], [44, 44], [45, 45], [46, 46], [47, 47], [48, 48], [49, 49], [50, 50], [51, 51],[52, 52], [53, 53], [54, 54], [55, 55], [56, 56], [57, 57], [58, 58], [59, 59], [60, 60], [61, 61], [62, 62], [63, 63], [64, 64]].freeze
	
	MONTH_OPTIONS = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7,7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12]].freeze

	DAY_OPTIONS = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7,7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]].freeze

end
