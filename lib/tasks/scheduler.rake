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
	SalaryRule.calculate_salaries 
	puts "Finished calculating salaries"
end

