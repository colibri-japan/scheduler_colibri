class ApplicationController < ActionController::Base
  include PublicActivity::StoreController 
  include Pundit
  
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
  	added_attrs = [ :name, :kana, :email, :password, :password_confirmation, :remember_me ]
  	devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
  	devise_parameter_sanitizer.permit :account_update, keys: added_attrs	
    devise_parameter_sanitizer.permit :sign_in, keys: [ :email, :password, :password_confirmation, :remember_me ]   
  	devise_parameter_sanitizer.permit :accept_invitation, keys: [ :email] 
  end

  private 

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end

end



