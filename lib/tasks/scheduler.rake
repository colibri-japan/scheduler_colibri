desc "Heroku scheduler tasks"

task :send_reminders => :environment do 
	puts "Sending reminders to nurses"
	Nurse.service_reminder 
	puts "Finished sending reminders"
end

task :mark_reminderable_posts_as_unread => :environment do
	puts "Marking reminderable posts as unread"
	Post.mark_reminderable_as_unread
	puts "Finished marking posts as unread"
end 

task :calculate_salaries_from_salary_rules => :environment do 
	puts "Starting to calculate salaries from salary rules"
	now_in_Japan = Time.current + 9.hours
	corporation_ids = SalaryRule.not_expired_at(now_in_Japan).pluck(:corporation_id).uniq
	nurse_ids = Nurse.displayable.where(corporation_id: corporation_ids).pluck(:id)
	year = now_in_Japan.year
	month = now_in_Japan.month
	nurse_ids.each do |nurse_id|
		RecalculateProvidedServicesFromSalaryRulesWorker.perform_async(nurse_id, year, month)
	end
	puts "Finished calculating salaries"
end

task :increment_days_worked => :environment do 
	puts "incrementing days worked for nurses that have worked yesterday"
	Nurse.increment_days_worked_if_has_worked_yesterday
	puts "finished incrementing days worked"
end

task :refresh_target_nurses_for_salary_rules => :environment do
	puts "updating targeted nurses for salary rules with nurse filter"
	SalaryRule.refresh_targeted_nurses
	puts "finished updating targeted nurses"
end

