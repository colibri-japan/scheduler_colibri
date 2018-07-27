class PlanningsController < ApplicationController

	before_action :set_corporation
	before_action :set_planning, only: [:show, :destroy, :master, :duplicate_from, :duplicate]
	before_action :set_nurses, only: [:show]
	before_action :set_patients, only: [:show]

	def index
		@plannings = @corporation.plannings.all
	end

	def show
		authorize @planning, :is_employee?
		
		set_valid_range
		@activities = PublicActivity::Activity.where(planning_id: @planning.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)
	end

	def new
		@planning = Planning.new
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

	def duplicate_from
		@plannings = @corporation.plannings.all - [@planning]
	end

	def duplicate
		ids = @corporation.plannings.ids


		if ids.include?(params[:template_id].to_i)
			template_planning = Planning.find(params[:template_id]) 

			original_appointments = template_planning.recurring_appointments.where(displayable: true)

			original_appointments.each do |appointment|
				#get the new anchor day in the new month
				original_day_wday = appointment.anchor.wday
				first_day = Date.new(@planning.business_year, @planning.business_month, 1)
				first_day_wday = first_day.wday

				first_day_wday > original_day_wday ? new_anchor_day = first_day + 7 - (first_day_wday - original_day_wday) : new_anchor_day = first_day + (original_day_wday - first_day_wday)

				#create new recurring_appointment with updated anchor
				recurring_appointment = appointment.dup 
				recurring_appointment.planning_id = @planning.id
				recurring_appointment.anchor = new_anchor_day
				recurring_appointment.start = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, appointment.start.hour, appointment.start.min)
				recurring_appointment.end = DateTime.new(new_anchor_day.year, new_anchor_day.month, new_anchor_day.day, appointment.end.hour, appointment.end.min)
				recurring_appointment.master = true
				recurring_appointment.displayable = true
				recurring_appointment.original_id = ''

				#save the duplicated recurring appointment to the new planning
				recurring_appointment.save
			end

			redirect_to @planning, notice: 'サービスのコピーが成功しました。'

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

		set_valid_range
		@admin = current_user.admin.to_s
		puts "this is @admin"
		puts @admin
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
		@nurses = @corporation.nurses.order(id: 'asc')
	end

	def set_patients
		@patients = @corporation.patients.order(id: 'asc')
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end



end
