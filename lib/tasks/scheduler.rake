desc "Heroku scheduler tasks"


task :create_base_corporation => :environment do 
	puts "Creating base corporation"
	User.assign_to_base_corporation
	puts "assigned to corporation"
end

task :provided_services => :environment do 
	puts "Marking today's services as provided"
	RecurringAppointment.count_as_payable
	puts "Today's services counted as payable"
end

task :add_title_to_provided_services => :environment do
	puts "Adding title to previously saved provided services"
	ProvidedService.add_title 
	puts "Finished adding titles"
end

task :add_nurse_patient_to_activities => :environment do
	puts "Adding nurse and patient to previous activities"
	PublicActivity::Activity.all.each do |activity|
		activity.nurse_id = activity.trackable.nurse_id if activity.trackable.present?
		activity.patient_id = activity.trackable.patient_id if activity.trackable.present?
		activity.save 
	end
	puts "Finished adding nurse and patients"
end

task :add_title_to_plannings => :environment do 
	puts "Adding title to existing plannings"
	Planning.add_title
	puts "Finished adding title to Plannings"
end

task :send_reminders => :environment do 
	puts "Sending reminders to nurses"
	Nurse.service_reminder 
	puts "Finished sending reminders"
end

task :add_undefined_nurse => :environment do 
	puts "adding default nurse"
	Corporation.add_undefined_nurse
	puts "finished adding undefined nurses"
end
