desc "Heroku scheduler tasks"


task :create_base_corporation => :environment do 
	puts "Creating base corporation"
	User.assign_to_base_corporation
	puts "assigned to corporation"
end