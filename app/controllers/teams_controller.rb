class TeamsController < ApplicationController

    before_action :set_corporation
    before_action :set_team, except: [:new, :index, :create]

    def index 
        @planning = @corporation.planning 
        set_main_nurse
        @teams = @corporation.teams.includes(:nurses)
        @nurses_without_any_team = @corporation.nurses.displayable.where(team_id: nil)
    end

    def new 
        authorize current_user, :has_admin_access?
        
        @team = Team.new()
    end
    
    def create
        authorize current_user, :has_admin_access?
        
        @team = @corporation.teams.new(team_params)
        
        if @team.save 
            redirect_to teams_path, notice: '新規チームが登録されました'
        end
    end

    def edit
        authorize current_user, :has_admin_access?
    end


    def update
        authorize current_user, :has_admin_access?

        if @team.update(team_params)
            redirect_to teams_path, notice: 'チーム情報がアップデートされました。'
        end
    end

    def delete
    end


    def payable
        @planning = Planning.find(params[:planning_id])

        authorize current_user, :has_access_to_salary_line_items?
        authorize @planning, :same_corporation_as_current_user?
        authorize @team, :same_corporation_as_current_user?

        set_month_and_year_params

        @nurse = current_user.nurse_id.present? ? current_user.nurse : @team.nurses.displayable.order_by_kana.first
        fetch_nurses_grouped_by_team
        fetch_patients_grouped_by_kana
    end

    def revenue_per_nurse_report
		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day

        @revenue_per_nurse = @team.revenue_per_nurse(first_day..last_day)
        @salary_per_nurse = @team.salary_per_nurse(first_day..last_day)
    end


	def new_master_to_schedule
        authorize current_user, :has_admin_access?
	end

    def master_to_schedule
        authorize current_user, :has_admin_access?
        authorize @team, :same_corporation_as_current_user?
        
		CopyTeamPlanningFromMasterWorker.perform_async(@team.id, params[:month], params[:year])

		@team.create_activity :reflect_team_master, owner: current_user, parameters: {year: params[:year].to_i, month: params[:month].to_i, team_name: @team.team_name}
    end
    
    def completion_reports_summary
        set_planning
        authorize @planning, :same_corporation_as_current_user?
        authorize current_user, :has_access_to_salary_line_items?

        set_main_nurse
        fetch_patients_grouped_by_kana
        set_reports_date
        nurse_ids = @team.nurses.ids
    
        @completion_reports = @planning.completion_reports.from_appointments.joins_appointments.includes(reportable: [:nurse, :second_nurse, :patient]).in_range(@date.beginning_of_day..@date.end_of_day).where(appointments: {nurse_id: nurse_ids}).order('appointments.starts_at DESC')
        @appointments_without_reports = @planning.appointments.operational.where(nurse_id: nurse_ids).left_outer_joins(:completion_report).where(completion_reports: {id: nil}).includes(:nurse, :patient).in_range(@date.beginning_of_day..@date.end_of_day).order(starts_at: :desc)
      
        respond_to do |format|
          format.html 
          format.html.phone 
        end
    end

    private

    def set_team
        @team = Team.find(params[:id])
    end

	def set_reports_date
		if params[:reports_date].present?
			@date = params[:reports_date].to_date rescue Date.today 
		else
			@date = Date.today
		end
	end

    def team_params
        params.require(:team).permit(:team_name, :phone_number, :fax_number, member_ids: [])
    end

    def set_month_and_year_params
        @selected_year = params[:y].present? ? params[:y] : Date.today.year
        @selected_month = params[:m].present? ? params[:m] : Date.today.month
    end
end