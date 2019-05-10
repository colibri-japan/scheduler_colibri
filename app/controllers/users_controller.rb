class UsersController < ApplicationController
  before_action :set_corporation

  def index
    authorize current_user, :has_admin_access?
    @planning = @corporation.planning 
    set_main_nurse
    
    @users = @corporation.users.all.order_by_kana
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
  
  private

  def user_role_params
    params.require(:user).permit(:role)
  end

end
