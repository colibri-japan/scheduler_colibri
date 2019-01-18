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
        @nurse = current_user.nurse_id.present? ? current_user.nurse : @team.nurses.displayable.order_by_kana.first
        fetch_nurses_grouped_by_team

    	#appointments : since beginning of month
        today = Date.today 
        nurse_ids = @team.nurses.displayable.ids
        appointments = Appointment.valid.edit_not_requested.where(planning_id: @planning.id, nurse_id: nurse_ids, master: false, starts_at: today.beginning_of_month.beginning_of_day..today.end_of_day ).includes(:patient, :nurse)

	    #daily summary
    	@appointments_grouped_by_title = appointments.where(starts_at: today.beginning_of_day..today.end_of_day).group_by(&:title)
    	@female_patients_ids = @corporation.patients.where(gender: true).ids 
    	@male_patients_ids = @corporation.patients.where(gender: false).ids
		
    	#weekly summary, from monday to today
    	@weekly_appointments_grouped_by_title = appointments.where(starts_at: (today - (today.strftime('%u').to_i - 1).days).beginning_of_day..today.end_of_day).group_by(&:title)

		#monthly summary, until end of today
		@monthly_appointments_grouped_by_title = appointments.group_by(&:title)
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

    def set_corporation
        @corporation = current_user.corporation 
    end

    def fetch_nurses_grouped_by_team
		@nurses = @corporation.nurses.displayable.order_by_kana
		if @corporation.teams.any?
			@team_name_by_id = @corporation.teams.pluck(:id, :team_name).to_h
			puts @team_name_by_id
			@grouped_nurses = @nurses.group_by {|nurse| @team_name_by_id[nurse.team_id] }
		else
			nurses_grouped_by_full_timer = @nurses.group_by {|nurse| nurse.full_timer}
			full_timers = nurses_grouped_by_full_timer[true] ||= []
			part_timers = nurses_grouped_by_full_timer[false] ||= []
			@grouped_nurses = {'正社員' => full_timers, '非正社員' => part_timers }
		end
	end
end