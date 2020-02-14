class UsersController < ApplicationController
  before_action :set_corporation

  def index
    authorize current_user, :has_admin_access?
    @planning = @corporation.planning 
    set_main_nurse
    
    @users = @corporation.users.all.order_by_kana

    fresh_when etag: @users, last_modified: @users.maximum(:updated_at)
  end

  def edit_role
    authorize current_user, :has_corporation_admin_role?

    @user = User.find(params[:id])
  end

  def update_role
    authorize current_user, :has_corporation_admin_role?

    @user = User.find(params[:id])

    if @user.update(user_role_params)
      redirect_to users_path
    end
  end

  def current_user_home
    if params[:to].present? && params[:to] == "planning"
      puts 'detected params to ; params force list view:'
      puts params[:force_list_view]
      redirect_to planning_path(@corporation.planning, force_list_view: params[:force_list_view])
    else
      if current_user.has_admin_access?
        redirect_to dashboard_index_path
      else
        redirect_to @corporation.planning
      end
    end
  end
  
  private

  def user_role_params
    params.require(:user).permit(:role)
  end

end
