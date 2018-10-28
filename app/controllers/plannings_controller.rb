class PlanningsController < ApplicationController

	before_action :set_corporation
	before_action :set_planning, only: [:show, :destroy, :master, :archive, :master_to_schedule, :duplicate_from, :duplicate, :settings]
	before_action :set_nurses, only: [:show]
	before_action :set_patients, only: [:show, :master]

	def index
		@plannings = @corporation.plannings.where(archived: false)
	end

	def show
		authorize @planning, :is_employee?
		authorize @planning, :is_not_archived?

		set_valid_range
		@last_patient = @patients.last
		@last_nurse = @nurses.last
		@activities = PublicActivity::Activity.where(planning_id: @planning.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)
	end

	def new
		if @corporation.nurses.count < 2
			redirect_to nurses_path, notice: 'スケジュールを作成する前にヘルパーを追加してください'
		elsif @corporation.patients.empty?
			redirect_to patients_path, notice: 'スケジュールを作成する前に利用者を追加してください'
		else
			@planning = Planning.new
		end
	end

	def create
		@planning = Planning.new(planning_params)
		@planning.corporation_id = current_user.corporation_id

		respond_to do |format|
			if @planning.save
				format.html { redirect_to planning_duplicate_from_path(@planning), notice: 'スケジュールがセーブされました'}
				format.js
			else
				format.html { render :new }
				format.js
			end
		end
	end

	def master_to_schedule
		authorize @planning, :is_employee?
		authorize current_user, :is_admin?

	    RecurringAppointment.where(planning_id: @planning.id, master: false).delete_all
		Appointment.where(planning_id: @planning.id, master: false).delete_all
		ProvidedService.where(planning_id: @planning.id).delete_all

		new_recurring_appointments = []
		new_appointments = []
		new_provided_services = []

		initial_recurring_appointments_count = RecurringAppointment.where(planning_id: @planning.id, master: true, displayable: true, edit_requested: false, deactivated: false, deleted: false).count
		initial_appointments_count = Appointment.valid.edit_not_requested.where(planning_id: @planning.id, master: true).where.not(recurring_appointment_id: nil).count

		RecurringAppointment.valid.edit_not_requested.where(planning_id: @planning.id, master: true).find_each do |recurring_appointment|
			new_recurring_appointment = recurring_appointment.dup 
			new_recurring_appointment.master = false 
			new_recurring_appointment.original_id = recurring_appointment.id
			new_recurring_appointment.skip_appointments_callbacks = true 
			new_recurring_appointments << new_recurring_appointment
		end

		if initial_recurring_appointments_count == new_recurring_appointments.count 
			RecurringAppointment.import(new_recurring_appointments)
		end

		new_recurring_appointments.each do |recurring_appointment|
			Appointment.valid.where(recurring_appointment_id: recurring_appointment.original_id).find_each do |appointment|
				new_appointment = appointment.dup 
				new_appointment.master = false 
				new_appointment.recurring_appointment_id = recurring_appointment.id 
				new_appointments << new_appointment
			end
		end

		if initial_appointments_count == new_appointments.count 
			Appointment.import(new_appointments)
		end

		new_appointments.each do |appointment|
			provided_duration = appointment.ends_at - appointment.starts_at
		  	is_provided =  Time.current + 9.hours > appointment.starts_at
      		new_provided_service = ProvidedService.new(appointment_id: appointment.id, planning_id: appointment.planning_id, service_duration: provided_duration, nurse_id: appointment.nurse_id, patient_id: appointment.patient_id, deactivated: appointment.deactivated, provided: is_provided, temporary: false, title: appointment.title, hour_based_wage: @corporation.hour_based_payroll, service_date: appointment.starts_at, appointment_start: appointment.starts_at, appointment_end: appointment.ends_at)
      		new_provided_service.run_callbacks(:save) { false }
      		new_provided_services << new_provided_service
		end

		ProvidedService.import(new_provided_services)
  
	    redirect_to @planning, notice: 'マスタースケジュールが全体へ反映されました！'
	end

	def duplicate_from
		@plannings = @corporation.plannings.where(archived: false) - [@planning]
	end

	def duplicate
		template_planning = Planning.find(params[:template_id])
		authorize template_planning, :is_employee?

		first_day = Date.new(@planning.business_year, @planning.business_month, 1)
		last_day = Date.new(@planning.business_year, @planning.business_month, -1)

		new_recurring_appointments = []
		new_appointments = []

		initial_recurring_appointments_count = template_planning.recurring_appointments.where(master: true).valid.edit_not_requested.where.not(frequency: 2).count

		template_planning.recurring_appointments.valid.edit_not_requested.where(master: true).where.not(frequency: 2).find_each do |recurring_appointment|

			new_anchor_day = first_day.wday > recurring_appointment.anchor.wday ?  first_day + 7 - (first_day.wday - recurring_appointment.anchor.wday) :  first_day + (recurring_appointment.anchor.wday - first_day.wday)

			new_recurring_appointment = recurring_appointment.dup 
			new_recurring_appointment.planning_id = @planning.id
			new_recurring_appointment.anchor = new_anchor_day
			new_recurring_appointment.end_day = new_anchor_day + recurring_appointment.duration
			new_recurring_appointment.starts_at = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
			new_recurring_appointment.ends_at = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min)
			new_recurring_appointment.master = true
			new_recurring_appointment.displayable = true
			new_recurring_appointment.original_id = ''

			new_recurring_appointments << new_recurring_appointment
		end

		if new_recurring_appointments.count == initial_recurring_appointments_count
			RecurringAppointment.import(new_recurring_appointments)
		end

		new_recurring_appointments.each do |recurring_appointment|
			recurring_appointment_occurrences = recurring_appointment.appointments(first_day, last_day)

			recurring_appointment_occurrences.each do |occurrence|
				start_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.starts_at.hour, recurring_appointment.starts_at.min)
		    	end_time = DateTime.new(occurrence.year, occurrence.month, occurrence.day, recurring_appointment.ends_at.hour, recurring_appointment.ends_at.min) + recurring_appointment.duration.to_i
				new_appointment = Appointment.new(title: recurring_appointment.title, nurse_id: recurring_appointment.nurse_id, recurring_appointment_id: recurring_appointment.id, patient_id: recurring_appointment.patient_id, planning_id: recurring_appointment.planning_id, master: recurring_appointment.master, displayable: true, starts_at: start_time, ends_at: end_time, color: recurring_appointment.color, edit_requested: recurring_appointment.edit_requested, description: recurring_appointment.description)
				new_appointments << new_appointment
			end
		end

		Appointment.import(new_appointments)

		redirect_to planning_nurse_master_path(@planning, @corporation.nurses.where(displayable: true).first), notice: 'サービスのコピーが成功しました。'
	end

	def destroy
	  authorize @planning, :is_employee?

	  @planning.destroy
	  respond_to do |format|
	    format.html { redirect_to plannings_url, notice: 'サービスなどを含めて、スケジュールが削除されました。' }
	    format.json { head :no_content }
	    format.js
	  end
	end

	def archive
		if @planning.update(archived: true)
			redirect_to root_path, notice: 'スケジュールが削除されました。'
		end
	end

	def master
		authorize @planning, :is_employee?

		@full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    	@part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana

		@last_patient = @patients.last
    	@last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last
		@patients_firstless = @patients - [@patients.first]

		set_valid_range
		@admin = current_user.admin.to_s
	end

	def settings 
		@services = @corporation.services.without_nurse_id.order_by_title
		@last_nurse = @corporation.nurses.where(displayable: true).last
	end


	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def set_valid_range
		@start_valid = Date.new(@planning.business_year, @planning.business_month, 1).strftime("%Y-%m-%d")
	end

	def set_nurses
		@nurses = @corporation.nurses.order_by_kana
	end

	def set_patients
		@patients = @corporation.patients.where(active: true).order_by_kana
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end



end
