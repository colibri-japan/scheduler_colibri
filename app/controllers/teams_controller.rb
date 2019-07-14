class TeamsController < ApplicationController

    before_action :set_corporation

    def index 
        @planning = @corporation.planning 
        set_main_nurse
        @teams = @corporation.teams.includes(:nurses).where(nurses: {displayable: true})
        @nurses_without_any_team = @corporation.nurses.displayable.where(team_id: nil)

        fresh_when etag: @teams, last_modified: @teams.maximum(:updated_at)
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
    
    def show
        @planning = Planning.find(params[:planning_id])
        @team = Team.find(params[:id]) 

        authorize @planning, :same_corporation_as_current_user?
        authorize @team, :same_corporation_as_current_user?
        
        fetch_patients_grouped_by_kana
        fetch_nurses_grouped_by_team
    end
    
    def master 
        @planning = Planning.find(params[:planning_id])
        @team = Team.find(params[:id]) 
        
        authorize @planning, :same_corporation_as_current_user?
        authorize @team, :same_corporation_as_current_user?

        fetch_patients_grouped_by_kana
        fetch_nurses_grouped_by_team
    end

    def payable
        @planning = Planning.find(params[:planning_id])
        @team = Team.find(params[:id])

        authorize current_user, :has_access_to_provided_services?
        authorize @planning, :same_corporation_as_current_user?
        authorize @team, :same_corporation_as_current_user?

        set_month_and_year_params

        @nurse = current_user.nurse_id.present? ? current_user.nurse : @team.nurses.displayable.order_by_kana.first
        fetch_nurses_grouped_by_team
        fetch_patients_grouped_by_kana

    	#appointments : since beginning of month
        today = Date.today 
        nurse_ids = @team.nurses.displayable.ids
        appointments = Appointment.operational.where(planning_id: @planning.id, nurse_id: nurse_ids, starts_at: today.beginning_of_month.beginning_of_day..today.end_of_day ).includes(:patient, :nurse)

	    #daily summary
    	@daily_appointments = appointments.where(starts_at: today.beginning_of_day..today.end_of_day)
    	@female_patients_ids = @corporation.patients.where(gender: true).ids 
    	@male_patients_ids = @corporation.patients.where(gender: false).ids
		
    	#weekly summary, from monday to today
    	@weekly_appointments = appointments.where(starts_at: (today - (today.strftime('%u').to_i - 1).days).beginning_of_day..today.end_of_day)

		#monthly summary, until end of today
		@monthly_appointments = appointments
    	#daily provided_services to be verified
    	@daily_provided_services = ProvidedService.where(planning_id: @planning.id, nurse_id: nurse_ids, temporary: false, cancelled: false, archived_at: nil, service_date: Date.today.beginning_of_day..Date.today.end_of_day).from_appointments.includes(:patient, :nurse, :appointment).where(appointments: {edit_requested: false}).order(service_date: :asc).group_by {|provided_service| provided_service.nurse_id}
    end

    def edit
        authorize current_user, :has_admin_access?

        @team = Team.find(params[:id])
    end


    def update
        authorize current_user, :has_admin_access?

        @team = Team.find(params[:id])

        if @team.update(team_params)
            redirect_to teams_path, notice: 'チーム情報がアップデートされました。'
        end
    end

    def delete
    end

    private

    def team_params
        params.require(:team).permit(:team_name, :phone_number, :fax_number, member_ids: [])
    end

    def set_month_and_year_params
        @selected_year = params[:y].present? ? params[:y] : Date.today.year
        @selected_month = params[:m].present? ? params[:m] : Date.today.month
    end
end