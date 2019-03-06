class PlanningsController < ApplicationController
	before_action :set_corporation
	before_action :set_planning, except: [:recent_patients_report] 
	before_action :set_main_nurse, only: [:all_patients, :all_nurses, :settings]
	before_action :set_patients_grouped_by_kana, only: [:all_patients, :all_nurses]

	def all_patients
		authorize @planning, :is_employee?

		fetch_nurses_grouped_by_team
	end
	
	def all_nurses
		authorize @planning, :is_employee?

		fetch_nurses_grouped_by_team
	end

	def new_master_to_schedule
		authorize current_user, :has_admin_access?
	end

	def master_to_schedule
		authorize @planning, :is_employee?
		authorize current_user, :has_admin_access?

		CopyPlanningFromMasterWorker.perform_async(@planning.id, params[:month], params[:year])

	  redirect_to planning_all_nurses_path(@planning), notice: 'マスタースケジュールが全体へ反映されてます。数秒後にリフレッシュしてください'
	end

	def payable
		@nurse = @corporation.nurses.displayable.order_by_kana.first 

		fetch_nurses_grouped_by_team

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day

		@provided_services_till_today = ProvidedService.joins(:nurse).where(planning_id: @planning.id, cancelled: false, archived_at: nil, service_date: first_day..last_day)

		#shintai vs seikatsu
		shintai = @provided_services_till_today.where('title LIKE ? ', '%身%')
		seikatsu = @provided_services_till_today.where('title LIKE ?', '%生%')

		@provided_services_shintai_sum = shintai.sum(:total_wage)
		@provided_services_shintai_count = shintai.count
		@provided_services_seikatsu_sum = seikatsu.sum(:total_wage)
		@provided_services_seikatsu_count = seikatsu.count

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
    @daily_provided_services = ProvidedService.where(planning_id:  @planning.id, temporary: false, cancelled: false, archived_at: nil, service_date: last_day.beginning_of_day..last_day).includes(:patient, :nurse).order(service_date: :asc).group_by {|provided_service| provided_service.nurse_id}
	end

	def settings 
	end

	def monthly_general_report
		start_date = Date.new(params[:y].to_i, params[:m].to_i, 1).beginning_of_day
		end_date = Date.new(params[:y].to_i, params[:m].to_i, -1).end_of_day
		
		@provided_services = @planning.provided_services.where(temporary: false, archived_at: nil, cancelled: false, provided: true, countable: false, service_date: start_date..end_date).includes(:nurse, :appointment).where(appointments: {edit_requested: false})
		
		@service_names = @provided_services.order(:title).map(&:title).uniq

		@nurses = @corporation.nurses.displayable
		@service_counts_grouped_by_nurse = {}

		@nurses.each do |nurse|
			sub_hash = {}
			@service_names.each do |service_name|
				if @provided_services.where(nurse_id: nurse.id, title: service_name).exists?
					if @provided_services.where(nurse_id: nurse.id, title: service_name).first.hour_based_wage == true 
						sum_duration = @provided_services.where(nurse_id: nurse.id, title: service_name).sum(:service_duration)
						sub_hash[service_name] = sum_duration.to_f / (60 * 60)
					else
						sub_hash[service_name] = @provided_services.where(nurse_id: nurse.id, title: service_name).count
					end
				else
					sub_hash[service_name] = 0
				end
			end
			@service_counts_grouped_by_nurse[nurse.name] = sub_hash
		end
		
		respond_to do |format|
			format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="給与詳細.xlsx"'}
		end
	end

	def teams_report
		@service_counts_by_title_and_team = @corporation.monthly_service_counts_by_title_and_team(params[:range_start], params[:range_end])

		respond_to do |format|
			format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="チーム分け実績.xlsx"' }
		end
	end

	def recent_patients_report
		@recent_patients = @corporation.recent_patients(Date.today, 60)

		respond_to do |format|
			format.xlsx {  response.headers['Content-Disposition'] = "attachment; filename=\"新規利用者#{Date.today}.xlsx\""  }
		end
	end


	private

  def set_corporation
    @corporation = Corporation.cached_find(current_user.corporation_id)
  end

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def set_main_nurse
		@main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
	end

	def set_patients_grouped_by_kana
		@patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end

  def fetch_nurses_grouped_by_team
    if @corporation.teams.any?
      @grouped_nurses = @corporation.cached_displayable_nurses_grouped_by_team_name
      set_teams_id_by_name
    else
      @grouped_nurses = @corporation.cached_displayable_nurses_grouped_by_fulltimer
    end
  end

  def set_teams_id_by_name
      @teams_id_by_name = @corporation.cached_team_id_by_name
	end

end
