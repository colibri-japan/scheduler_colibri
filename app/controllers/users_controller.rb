class UsersController < ApplicationController
  before_action :set_corporation

  def index
    authorize current_user, :is_admin?
    @users = @corporation.users.all.order_by_kana
  end

  def edit_role
    @user = User.find(params[:id])
  end

  def update_role
    @user = User.find(params[:id])

    if @user.update(user_role_params)
      redirect_to users_path
    end
  end
  
  private

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end

  def user_role_params
    params.require(:user).permit(:role)
  end

end
