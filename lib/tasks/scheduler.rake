desc "Heroku scheduler tasks"

task :send_reminders => :environment do 
	puts "Sending reminders to nurses"
	Nurse.service_reminder 
	puts "Finished sending reminders"
end

