class PlanningsController < ApplicationController

	before_action :set_corporation
	before_action :set_planning, only: [:show, :destroy, :master, :master_to_schedule, :duplicate_from, :duplicate]
	before_action :set_nurses, only: [:show, :master]
	before_action :set_patients, only: [:show, :master]

	def index
		@plannings = @corporation.plannings.all
	end

	def show
		authorize @planning, :is_employee?
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

	    RecurringAppointment.where(planning_id: @planning.id, master: false).destroy_all
	    Appointment.where(planning_id: @planning.id, master: false).destroy_all

	    puts 'appointments destroyed'
  
	    master_appointments = Appointment.where(planning_id: @planning.id, master: true, displayable: true, edit_requested: false, deactivated: false, deleted: false)

	    puts 'master appointments count'
	    puts master_appointments.count

	    library = {}
  
	    master_appointments.each do |master_appointment|
	      appointment_copy = master_appointment.dup
	      appointment_copy.master = false
	      appointment_copy.original_id = nil
	      puts 'appointment_copy dup successful'
	      if appointment_copy.recurring_appointment_id.present?
	      	puts 'appointment_copy recurring_appointment_id present'
	      	if library[appointment_copy.recurring_appointment_id].present?
	      		puts 'library already present'
	      		puts library
	      		appointment_copy.recurring_appointment_id = library[appointment_copy.recurring_appointment_id]
	      	else
	      		puts 'no library found'
	      		puts library
		      	original_recurring_appointment = RecurringAppointment.find(appointment_copy.recurring_appointment_id)
		      	new_recurring_appointment = original_recurring_appointment.dup
		      	new_recurring_appointment.master = false
		      	new_recurring_appointment.original_id = nil
		      	new_recurring_appointment.skip_appointments_callbacks = true
		      	puts 'new recurring_appointment dup successful'
		      	new_recurring_appointment.save!(validate: false)

		      	puts 'new recurring_appointment save successful'

		      	library[appointment_copy.recurring_appointment_id] = new_recurring_appointment.id
		      	appointment_copy.recurring_appointment_id = new_recurring_appointment.id


		      	puts 'library updated'
		      	puts library
	      	end
	      end

	      puts 'before saving appointment'
	      appointment_copy.save!(validate: false)
	      puts 'appointment saved'
	    end

	    puts 'all appointments saved'
	    puts 'library:'
	    puts library
  
	    redirect_to @planning, notice: 'マスタースケジュールが全体へ反映されました！'
	end

	def duplicate_from
		@plannings = @corporation.plannings.all - [@planning]
	end

	def duplicate
		ids = @corporation.plannings.ids


		if ids.include?(params[:template_id].to_i)
			template_planning = Planning.find(params[:template_id]) 

			original_appointments = template_planning.recurring_appointments.where(master: true, displayable: true, frequency: [0,1], edit_requested: false, deactivated: false, deleted: [nil, false]).all

			original_appointments.each do |appointment|
				original_day_wday = appointment.anchor.wday
				first_day = Date.new(@planning.business_year, @planning.business_month, 1)
				first_day_wday = first_day.wday

				first_day_wday > original_day_wday ? new_anchor_day = first_day + 7 - (first_day_wday - original_day_wday) : new_anchor_day = first_day + (original_day_wday - first_day_wday)

				recurring_appointment = appointment.dup 
				recurring_appointment.planning_id = @planning.id
				recurring_appointment.anchor = new_anchor_day
				recurring_appointment.end_day = new_anchor_day + appointment.duration
				recurring_appointment.start = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, appointment.start.hour, appointment.start.min)
				recurring_appointment.end = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, appointment.end.hour, appointment.end.min)
				recurring_appointment.master = true
				recurring_appointment.displayable = true
				recurring_appointment.original_id = ''

				recurring_appointment.save!(validate: false)
			end

			redirect_to planning_master_path(@planning), notice: 'サービスのコピーが成功しました。'

		else
			redirect_to planning_duplicate_from_path(@planning), notice: 'このスケジュールはコピーできません。'
		end



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

	def master
		authorize @planning, :is_employee?

		@last_patient = @patients.last
		@last_nurse = @nurses.last
		@patients_firstless = @patients - [@patients.first]

		set_valid_range
		@admin = current_user.admin.to_s
	end


	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def set_valid_range
		valid_month = @planning.business_month
		valid_year = @planning.business_year
		@start_valid = Date.new(valid_year, valid_month, 1).strftime("%Y-%m-%d")
		@end_valid = Date.new(valid_year, valid_month +1, 1).strftime("%Y-%m-%d")
	end

	def set_nurses
		@nurses = @corporation.nurses.order_by_kana
	end

	def set_patients
		@patients = @corporation.patients.order_by_kana
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end



end
