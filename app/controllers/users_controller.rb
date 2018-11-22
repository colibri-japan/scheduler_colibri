class UsersController < ApplicationController
  before_action :set_corporation

  def index
    authorize current_user, :is_admin?
    @users = @corporation.users.all.order_by_kana
  end

  def toggle_admin
    @user = User.find(params[:id])
    @user.toggle!(:admin)

    redirect_to users_path, notice: 'ユーザーの権限が変更されました'
  end
  
  private

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end

end
