class UsersController < ApplicationController
  before_action :set_corporation

  def index
    authorize current_user, :is_admin?
    @users = @corporation.users.all 
  end

  def toggle_admin
    @user = User.find(params[:id])
    @user.toggle!(:admin)

    respond_to do |format|
      format.js
    end
  end
  
  private

  def set_corporation
  	@corporation = Corporation.find(current_user.corporation_id)
  end

end
