class Appointment < ApplicationRecord
	include PublicActivity::Common

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'Appointment', optional: true
	belongs_to :recurring_appointment, optional: true
	has_one :provided_service, dependent: :destroy

	validates :title, presence: true
	validate :do_not_overlap
	validate :edit_requested_and_undefined_nurse

	before_create :default_master
	before_create :default_displayable

	after_create :create_provided_service
	after_update :update_provided_service
	after_save :add_to_services

	def all_day_appointment?
		puts 'checking if all day appointments'
		self.start == self.start.midnight && self.end == self.end.midnight ? true : false
	end

	def weekend_holiday_appointment?
		!self.start.on_weekday? || !self.end.on_weekday? || HolidayJp.between(self.start, self.end).present? ? true : false
	end

	private

	def do_not_overlap
		nurse = Nurse.find(self.nurse_id)

		puts 'overlap validation on appointment'

		unless nurse.name == '未定' || self.displayable == false
			overlaps_start = Appointment.where(master: self.master, displayable: true, start: self.start..self.end, edit_requested: false, nurse_id: self.nurse_id).where.not(start: self.start).where.not(start: self.end).where.not(id: [self.id, self.original_id])
			overlaps_end = Appointment.where(master: self.master, displayable: true, end: self.start..self.end, edit_requested: false, nurse_id: self.nurse_id).where.not(end: self.start).where.not(end: self.end).where.not(id: [self.id,self.original_id])

			errors.add(:nurse_id, "その日のヘルパーが重複しています。") if overlaps_start.present? || overlaps_end.present?
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
		  provided_duration = self.end - self.start
		  is_provided =  Time.current + 9.hours > self.start
		  provided_service = ProvidedService.create!(appointment_id: self.id, planning_id: self.planning_id, service_duration: provided_duration, nurse_id: self.nurse_id, patient_id: self.patient_id, deactivated: self.deactivated, provided: is_provided, temporary: false, title: self.title, hour_based_wage: self.planning.corporation.hour_based_payroll, service_date: self.start, appointment_start: self.start, appointment_end: self.end)
		end
	end

	def update_provided_service
		puts 'updating provided service'
		if self.master != true
			@provided_service = ProvidedService.where(appointment_id: self.id)
			if self.deleted == true 
				@provided_service.update(deactivated: true)
			else
		      provided_duration = self.end - self.start
		      is_provided = Time.current + 9.hours > self.start
		      deactivate_provided =  self.displayable == false || self.deleted == true || self.deactivated == true
			  @provided_service.update(service_duration: provided_duration, planning_id: self.planning_id, nurse_id: self.nurse_id, patient_id: self.patient_id, title: self.title, deactivated: deactivate_provided, provided: is_provided, service_date: self.start, appointment_start: self.start, appointment_end: self.end)
			end
		end
	end

	def add_to_services
		services = Service.where(corporation_id: self.planning.corporation.id, title: self.title)

		if services.blank? 
			self.planning.corporation.services.create(title: self.title)
		end
	end

	def self.update_activities
		update_activities = PublicActivity::Activity.where(key: 'appointment.update', new_start: nil, new_end: nil)

		update_activities.each do |activity|
			if activity.trackable.present?
			  activity.new_start = activity.trackable.start
			  activity.new_end = activity.trackable.end 
			  activity.new_nurse = activity.trackable.nurse.name if activity.trackable.nurse.present? 
			  activity.new_patient = activity.trackable.patient.name  if activity.trackable.patient.present?
			  activity.new_edit_requested = activity.trackable.edit_requested

			  activity.save! 
			end
		end
	end



end
