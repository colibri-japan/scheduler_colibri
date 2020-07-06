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

  def edit
    @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
    @planning = @corporation.planning
    @teams = current_user.corporation.teams

    @user = current_user
  end

  def update 
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_back fallback_location: current_user_home_path , notice: '個人情報が編集されました。'
    else
      redirect_back fallback_location: current_user_home_path, alert: '個人情報が編集できませんです。'
    end
  end

  def update_role
    authorize current_user, :has_corporation_admin_role?

    @user = User.find(params[:id])

    if @user.update(user_role_params)
      redirect_to users_path
    end
  end

  def current_user_home
    mark_notification_as_read

    if params[:to].present? && params[:to] == "planning"
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

  def mark_notification_as_read
    if params[:notification_id].present? 
      n = Rpush::Gcm::Notification.find(params[:notification_id])

      n.mark_as_read! for: current_user
    end
  end

  def user_role_params
    params.require(:user).permit(:role)
  end

  def user_params 
    params.require(:user).permit(:name, :kana, :nurse_id, :default_calendar_option, :team_id)
  end

end
