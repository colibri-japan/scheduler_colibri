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

end