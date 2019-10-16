desc "Heroku scheduler tasks"

task :send_reminders => :environment do 
	Nurse.send_service_reminder 
end

task :mark_reminderable_posts_as_unread => :environment do
	Post.mark_reminderable_as_unread
end 

task :calculate_salaries_from_salary_rules => :environment do 
	now_in_Japan = Time.current + 9.hours
	corporation_ids = SalaryRule.not_expired_at(now_in_Japan).pluck(:corporation_id).uniq
	nurse_ids = Nurse.displayable.where(corporation_id: corporation_ids).pluck(:id)
	year = now_in_Japan.year
	month = now_in_Japan.month
	nurse_ids.each do |nurse_id|
		RecalculateSalaryLineItemsFromSalaryRulesWorker.perform_async(nurse_id, year, month)
	end
end

