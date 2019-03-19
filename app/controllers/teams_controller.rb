class TeamsController < ApplicationController

    before_action :set_corporation

    def index 
        @teams = @corporation.teams.includes(:nurses).where(nurses: {displayable: true})
        @nurses_without_any_team = @corporation.nurses.displayable.where(team_id: nil)
    end

    def new 
        @team = Team.new()
    end

    def create
        @team = @corporation.teams.new(team_params)

        if @team.save 
            redirect_to teams_path, notice: '新規チームが登録されました'
        end
    end

    def show
        @planning = Planning.find(params[:planning_id])
        @team = Team.find(params[:id]) 
        set_main_nurse
        set_patients_grouped_by_kana
        fetch_nurses_grouped_by_team
    end

    def payable
        set_month_and_year_params

        @planning = Planning.find(params[:planning_id])
        @team = Team.find(params[:id])
        @nurse = current_user.nurse_id.present? ? current_user.nurse : @team.nurses.displayable.order_by_kana.first
        fetch_nurses_grouped_by_team

    	#appointments : since beginning of month
        today = Date.today 
        nurse_ids = @team.nurses.displayable.ids
        appointments = Appointment.valid.edit_not_requested.where(planning_id: @planning.id, nurse_id: nurse_ids, master: false, starts_at: today.beginning_of_month.beginning_of_day..today.end_of_day ).includes(:patient, :nurse)

	    #daily summary
    	@daily_appointments = appointments.where(starts_at: today.beginning_of_day..today.end_of_day)
    	@female_patients_ids = @corporation.patients.where(gender: true).ids 
    	@male_patients_ids = @corporation.patients.where(gender: false).ids
		
    	#weekly summary, from monday to today
    	@weekly_appointments = appointments.where(starts_at: (today - (today.strftime('%u').to_i - 1).days).beginning_of_day..today.end_of_day)

		#monthly summary, until end of today
		@monthly_appointments = appointments
    	#daily provided_services to be verified
    	@daily_provided_services = ProvidedService.where(planning_id: @planning.id, nurse_id: nurse_ids, temporary: false, cancelled: false, archived_at: nil, service_date: Date.today.beginning_of_day..Date.today.end_of_day).includes(:patient, :nurse).order(service_date: :asc).group_by {|provided_service| provided_service.nurse_id}
    end

    def edit
        @team = Team.find(params[:id])
    end


    def update
        @team = Team.find(params[:id])

        if @team.update(team_params)
            redirect_to teams_path, notice: 'チーム情報がアップデートされました。'
        end
    end

    def delete
    end

    private

    def team_params
        params.require(:team).permit(:team_name, member_ids: [])
    end

    def set_main_nurse
		@main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
    end
    
    def set_patients_grouped_by_kana
		@patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
	end

    def set_corporation
      @corporation = Corporation.cached_find(current_user.corporation_id)
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

    def set_month_and_year_params
        @selected_year = params[:y].present? ? params[:y] : Date.today.year
        @selected_month = params[:m].present? ? params[:m] : Date.today.month
    end
end