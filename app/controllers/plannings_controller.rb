class PlanningsController < ApplicationController
	before_action :set_corporation
	before_action :set_planning, except: [:recent_patients_report] 
	before_action :fetch_patients_grouped_by_kana, only: [:all_patients, :all_nurses, :all_patients_master, :all_nurses_master]
	before_action :fetch_nurses_grouped_by_team, only: [:all_patients, :all_nurses, :all_patients_master, :all_nurses_master]

	def all_patients
		authorize @planning, :same_corporation_as_current_user?
	end
	
	def all_nurses
		authorize @planning, :same_corporation_as_current_user?
		@nurses = @corporation.nurses.displayable
	end
	
	def all_patients_master
		authorize @planning, :same_corporation_as_current_user?
	end
	
	def all_nurses_master
		authorize @planning, :same_corporation_as_current_user?
		@nurses = @corporation.nurses.displayable
	end

	def new_master_to_schedule
		authorize current_user, :has_admin_access?
	end

	def master_to_schedule
		authorize @planning, :same_corporation_as_current_user?
		authorize current_user, :has_admin_access?

		CopyPlanningFromMasterWorker.perform_async(@planning.id, params[:month], params[:year])

		@planning.create_activity :reflect_all_master, owner: current_user, planning_id: @planning.id, parameters: {year: params[:year].to_i, month: params[:month].to_i}
		
	    redirect_to planning_all_nurses_path(@planning), notice: 'マスタースケジュールが全体へ反映されてます。数秒後にリフレッシュしてください'
	end

	def all_nurses_payable
		authorize current_user, :has_access_to_provided_services?
		
		@nurse = @corporation.nurses.displayable.order_by_kana.first 

		set_month_and_year_params
		fetch_nurses_grouped_by_team
		fetch_patients_grouped_by_kana

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day

		@provided_services_till_today = ProvidedService.joins(:nurse).where(planning_id: @planning.id, cancelled: false, archived_at: nil, service_date: first_day..last_day)


		#appointments : since beginning of month
		today = Date.today
		appointments = Appointment.valid.edit_not_requested.where(planning_id: @planning.id, master: false, starts_at: first_day..last_day).includes(:patient, :nurse)
		
		#daily summary
		@daily_appointments = appointments.where(starts_at: last_day.beginning_of_day..last_day)
    	@female_patients_ids = @corporation.patients.where(gender: true).ids
    	@male_patients_ids = @corporation.patients.where(gender: false).ids
		
    	#weekly summary, from monday to today
    	@weekly_appointments = appointments.where(starts_at: (last_day - (last_day.strftime('%u').to_i - 1).days).beginning_of_day..last_day)

		#monthly summary, until end of today
		@monthly_appointments = appointments

    	#daily provided_services to be verified
    	@daily_provided_services = ProvidedService.where(planning_id:  @planning.id, temporary: false, cancelled: false, archived_at: nil, service_date: last_day.beginning_of_day..last_day).from_appointments.includes(:patient, :nurse, :appointment).where(appointments: {edit_requested: false}).order(service_date: :asc).group_by {|provided_service| provided_service.nurse_id}
	end

	def all_patients_payable
		authorize current_user, :has_access_to_provided_services?

		set_month_and_year_params
		fetch_nurses_grouped_by_team
		fetch_patients_grouped_by_kana

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day
		
		@care_manager_corporations = @corporation.care_manager_corporations
	end

	def monthly_general_report
		start_date = Date.new(params[:y].to_i, params[:m].to_i, 1).beginning_of_day
		end_date = Date.new(params[:y].to_i, params[:m].to_i, -1).end_of_day
		
		@service_hour_based_hash = @corporation.services.delivered_in_range(start_date..end_date).order(:title).pluck(:title, :hour_based_wage).uniq.to_h

		@provided_services_count_and_sum_duration_by_nurse = @corporation.nurses.displayable.provided_services_count_and_sum_duration_for(start_date..end_date)
		
		respond_to do |format|
			format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="給与詳細.xlsx"'}
		end
	end

	def teams_report
		if @corporation.teams.exists?
			@service_counts_by_title_and_team = @corporation.monthly_service_counts_by_title_and_team(params[:range_start], params[:range_end])
		else
			@service_counts_by_title_and_team = @corporation.service_counts_by_title_in_range(params[:range_start], params[:range_end])
		end

		@patients_count = @corporation.patients.active.count

		respond_to do |format|
			format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="チーム分け実績.xlsx"' }
		end
	end

	def recent_patients_report
		@recent_patients = @corporation.patients_with_contract_starting_after(Date.today - 60.days)

		respond_to do |format|
			format.xlsx {  response.headers['Content-Disposition'] = "attachment; filename=\"新規利用者#{Date.today}.xlsx\""  }
		end
	end


	private

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end

	def set_month_and_year_params
		@selected_year = params[:y].present? ? params[:y] : Date.today.year
    @selected_month = params[:m].present? ? params[:m] : Date.today.month
	end

end
