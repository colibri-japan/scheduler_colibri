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