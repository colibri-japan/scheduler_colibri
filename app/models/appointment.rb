class Appointment < ApplicationRecord
	include PublicActivity::Common

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'Appointment', optional: true
	belongs_to :recurring_appointment, optional: true
	belongs_to :service, optional: true
	has_one :provided_service, dependent: :destroy

	validates :title, presence: true
	validate :do_not_overlap
	validate :edit_requested_and_undefined_nurse
	
	before_create :default_master
	before_create :default_displayable
	before_save :add_to_services

	after_create :create_provided_service
	after_update :update_provided_service

	scope :valid, -> { where(deactivated: false, displayable: true, deleted: [false,nil]) }
	scope :edit_not_requested, -> { where(edit_requested: false) }
	scope :from_master, -> { where(master: true) }


	def all_day_appointment?
		puts 'checking if all day appointments'
		self.starts_at == self.starts_at.midnight && self.ends_at == self.ends_at.midnight ? true : false
	end

	def weekend_holiday_appointment?
		!self.starts_at.on_weekday? || !self.ends_at.on_weekday? || HolidayJp.between(self.starts_at, self.ends_at).present? ? true : false
	end

	def self.overlapping(range)
		where('((starts_at >= ? AND starts_at < ?) OR (ends_at > ? AND ends_at <= ?)) OR (starts_at < ? AND ends_at > ?)', range.first, range.last, range.first, range.last, range.first, range.last)
	end

	private

	def do_not_overlap
		nurse = Nurse.find(self.nurse_id)

		puts 'overlap validation on appointment'

		unless nurse.name == '未定' || self.displayable == false
			overlaps = Appointment.where(master: self.master, displayable: true, edit_requested: false, planning_id: self.planning_id, nurse_id: self.nurse_id).where.not(id: self.id).overlapping(self.starts_at..self.ends_at).exists?

			errors.add(:nurse_id, "その日のヘルパーが重複しています。") if overlaps
		end
	end


	def default_master
		puts 'setting default master'
		self.master ||= false
	end

	def default_displayable
		puts 'setting default displayable'
		self.displayable = true if self.displayable.nil?
	end

	def edit_requested_and_undefined_nurse
		puts 'edit request and undefined nurse'
		nurse = Nurse.find(self.nurse_id)
		errors.add(:nurse_id, "ヘルパーを選択、または編集リストへ追加オプションを選択してください。") if nurse.name == '未定' && self.edit_requested.blank?
	end

	def create_provided_service
		puts 'adding provided service'
		if self.master != true
		  provided_duration = self.ends_at - self.starts_at
		  is_provided =  Time.current + 9.hours > self.starts_at
		  service_salary_id = self.planning.corporation.equal_salary ? self.service_id : Service.where(title: self.title, nurse_id: self.nurse_id, corporation_id: self.planning.corporation_id).first.id
		  puts 'just before saving provided service'
		  puts self.nurse_id
		  provided_service = ProvidedService.create!(appointment_id: self.id, planning_id: self.planning_id, service_duration: provided_duration, nurse_id: self.nurse_id, patient_id: self.patient_id, deactivated: self.deactivated, provided: is_provided, temporary: false, title: self.title, hour_based_wage: self.planning.corporation.hour_based_payroll, service_date: self.starts_at, appointment_start: self.starts_at, appointment_end: self.ends_at, service_salary_id: service_salary_id)
		end
	end

	def update_provided_service
		puts 'updating provided service'
		if self.master != true
			@provided_service = ProvidedService.where(appointment_id: self.id)
			if self.deleted == true 
				@provided_service.update(deactivated: true)
			else
		      provided_duration = self.ends_at - self.starts_at
			  is_provided = Time.current + 9.hours > self.starts_at
			  if self.planning.corporation.equal_salary == true 
				service_salary_id = self.service_id
			  else 
				nurse_service =  Service.where(title: self.title, nurse_id: self.nurse_id, corporation_id: self.planning.corporation_id).first
				service_salary_id =  nurse_service.present? ? nurse_service.id : self.service_id
			  end
			   deactivate_provided =  self.displayable == false || self.deleted == true || self.deactivated == true
			  @provided_service.update(service_duration: provided_duration, planning_id: self.planning_id, nurse_id: self.nurse_id, patient_id: self.patient_id, title: self.title, deactivated: deactivate_provided, provided: is_provided, service_date: self.starts_at, appointment_start: self.starts_at, appointment_end: self.ends_at, service_salary_id: service_salary_id)
			end
		end
	end

	def add_to_services
		unless self.service_id.present?
			services = Service.where(corporation_id: self.planning.corporation.id, title: self.title, nurse_id: nil)

			if services.blank? 
				new_service = self.planning.corporation.services.create(title: self.title)
				self.service_id = new_service.id
			else
				self.service_id = services.first.id
			end
		end
	end

	def self.update_activities
		update_activities = PublicActivity::Activity.where(key: 'appointment.update', new_start: nil, new_end: nil)

		update_activities.each do |activity|
			if activity.trackable.present?
			  activity.new_start = activity.trackable.starts_at
			  activity.new_end = activity.trackable.ends_at 
			  activity.new_nurse = activity.trackable.nurse.name if activity.trackable.nurse.present? 
			  activity.new_patient = activity.trackable.patient.name  if activity.trackable.patient.present?
			  activity.new_edit_requested = activity.trackable.edit_requested

			  activity.save! 
			end
		end
	end

	def self.add_or_create_service
		appointments = Appointment.where(service_id: nil).where('starts_at > ?', Date.new(2018,10,1)) 

		appointments.find_each do |appointment|
			service = Service.where(corporation_id: appointment.planning.corporation.id, nurse_id: nil, title: appointment.title).first 
			if service.present? 
				appointment.service_id = service.id 
				appointment.save(validate: false)
			end
		end
	end



end
