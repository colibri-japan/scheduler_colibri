desc "Heroku scheduler tasks"


task :create_base_corporation => :environment do 
	puts "Creating base corporation"
	User.assign_to_base_corporation
	puts "assigned to corporation"
end

task :provided_services => :environment do 
	puts "Marking today's services as provided"
	Appointment.count_as_payable
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

task :add_color_to_appointments => :environment do 
	puts "adding default colors"
	RecurringAppointment.add_default_color
	puts "finished adding colors"
end

task :move_to_appointments => :environment do 
	puts "moving recurring appointments to appointments"
	RecurringAppointment.create_appointments
	puts "finished creating appointments"
end

task :mark_as_deleted => :environment do 
	puts "marking appointments and recurring_appointments that are non displayable as deleted"
	Appointment.mark_appointments_as_deleted
	RecurringAppointment.mark_recurring_appointments_as_deleted
	puts 'finished marking appointments and recurring appointments as deleted'
end

task :default_deleted => :environment do 
	puts 'deleted null for recurring appointments will be turned to false'
	RecurringAppointment.deleted_nil_to_false
	puts 'finished switching null to false for recurring appointments'
end

task :reset_provided_services => :environment do 
	puts 'delete existing provided services and create one for each appointment'
	ProvidedService.master_delete
	Appointment.create_individual_provided_service
	puts 'finished reseting provided services'
end

task :update_provided_services => :environment do 
	puts 'adding service date, appointment start and end to provided services'
	ProvidedService.add_service_date
	puts 'finished adding service dates'
end

task :default_duration_is_zero => :environment do 
	puts 'default service duration equals zero'
	ProvidedService.set_default_duration_to_zero
	puts 'finished task'
end

task :add_services_to_corporation => :environment do 
	puts 'adding services to corporation'
	Corporation.add_services 
	puts 'finished adding services'
end