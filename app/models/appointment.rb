class Appointment < ApplicationRecord
	include PublicActivity::Common

	belongs_to :nurse, optional: true
	belongs_to :patient, optional: true
	belongs_to :planning
	belongs_to :original, class_name: 'Appointment', optional: true
	belongs_to :recurring_appointment, optional: true
	has_one :provided_service

	validates :title, presence: true
	validate :do_not_overlap

	before_save :default_master
	before_save :default_displayable
	before_save :edit_request_from_nurse_name

	after_create :create_provided_service
	after_update :update_provided_service

	def all_day_appointment?
		self.start == self.start.midnight && self.end == self.end.midnight ? true : false
	end

	private

	def self.count_as_payable
		date = Date.today
		timezone = ActiveSupport::TimeZone['Asia/Tokyo']
		start_time = timezone.local(date.year, date.month, date.day)
		end_time = start_time.end_of_day

		appointments = Appointment.where(master: false, displayable: true, end: start_time..end_time, edit_requested: false, deleted: false, deactivated: false)

		appointments.each do |appointment|
			duration = appointment.end - appointment.start
			provided = ProvidedService.create!(payable: appointment, service_duration: duration, nurse_id: appointment.nurse_id, patient_id: appointment.patient_id, planning_id: appointment.planning_id, title: appointment.title)
		end

	end

	def do_not_overlap
		nurse = Nurse.find(self.nurse_id)

		puts 'do not overlap appointment called'

		unless nurse.name == '未定' || self.displayable == false
			overlaps_start = Appointment.where(master: self.master, displayable: true, start: self.start..self.end, edit_requested: false, nurse_id: self.nurse_id).where.not(start: self.start).where.not(start: self.end).where.not(id: [self.id, self.original_id])
			overlaps_end = Appointment.where(master: self.master, displayable: true, end: self.start..self.end, edit_requested: false, nurse_id: self.nurse_id).where.not(end: self.start).where.not(end: self.end).where.not(id: [self.id,self.original_id])

			puts 'overlapping it'
			puts overlaps_start.map {|e| e.id}
			puts overlaps_end.map{|e| e.id}
			errors.add(:nurse_id, "選択されたヘルパーはすでにその時間帯にサービスを提供してます") if overlaps_start.present? || overlaps_end.present?
		end
	end


	def default_master
		self.master = true if self.master.nil?
	end

	def default_displayable
		self.displayable = true if self.displayable.nil?
	end

	def edit_request_from_nurse_name
		nurse = Nurse.find(self.nurse_id)
		self.edit_requested = true if nurse.name == '未定'
	end

	def self.mark_appointments_as_deleted
		appointments_to_be_deleted = Appointment.where(displayable: false)

		appointments_to_be_deleted.each do |appointment_to_be_deleted|
			appointment_to_be_deleted.deleted = true
			appointment_to_be_deleted.deleted_at = Time.current
			appointment_to_be_deleted.save!(validate: false)
		end
	end

	def create_provided_service
		provided_duration = self.end - self.start
		is_provided =  Time.now.in_time_zone('Tokyo') > self.start
		provided_service = ProvidedService.create!(appointment_id: self.id, service_duration: provided_duration, nurse_id: self.nurse_id, patient_id: self.patient_id, deactivated: self.deactivated, provided: is_provided, temporary: false, title: self.title)
	end

	def update_provided_service
		provided_service = ProvidedService.where(appointment_id: self.id)
		provided_duration = self.end - self.start
		is_provided = Time.now.in_time_zone('Tokyo') > self.start
		deactivate_provided = true if self.displayable == false || self.deleted == true || self.deactivated == true || self.edit_requested == true
		provided_service.update(service_duration: provided_duration, nurse_id: self.nurse_id, patient_id: self.patient_id, title: self.title, deactivated: deactivate_provided, provided: is_provided)
	end

end
