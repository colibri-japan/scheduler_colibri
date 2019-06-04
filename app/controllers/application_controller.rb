class ApplicationController < ActionController::Base
  include PublicActivity::StoreController 
  include Pundit
  
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
  	added_attrs = [ :name, :kana, :nurse_id, :schedule_default_url_option, :email, :password, :password_confirmation, :remember_me ]
  	devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
  	devise_parameter_sanitizer.permit :account_update, keys: added_attrs	
    devise_parameter_sanitizer.permit :sign_in, keys: [ :email, :password, :password_confirmation, :remember_me ]   
  	devise_parameter_sanitizer.permit :accept_invitation, keys: [ :email, :name, :kana, :password, :password_confirmation] 
  end

  private 

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:alert] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || authenticated_root_path)
  end

  def set_corporation
    @corporation = Corporation.cached_find(current_user.corporation_id)
  end

  def fetch_nurses_grouped_by_team
    if @corporation.teams.any?
			@grouped_nurses = @corporation.cached_displayable_nurses_grouped_by_team_name
			reorder_nurses_grouped_by_team if current_user.nurse.present? && current_user.nurse.team.present?
      set_teams_id_by_name
    else
      @grouped_nurses = @corporation.cached_displayable_nurses_grouped_by_fulltimer
    end
	end
	
	def reorder_nurses_grouped_by_team
		my_team = current_user.nurse.team.team_name 
		new_keys = [[my_team] + [@grouped_nurses.keys - [my_team]]].flatten
		ordered_grouped_nurses = {}
		new_keys.map { |key| ordered_grouped_nurses[key] = @grouped_nurses[key] }
		@grouped_nurses = ordered_grouped_nurses
	end

  def set_teams_id_by_name
      @teams_id_by_name = @corporation.cached_team_id_by_name
  end

  def set_main_nurse
		@main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
  end
  
  def fetch_patients_grouped_by_kana
		@patients_grouped_by_kana = @corporation.cached_active_patients_grouped_by_kana
	end
  
end



