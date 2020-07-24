module Api
    class BaseController < ActionController::API
        include Knock::Authenticable
        undef_method :current_user
        before_action :authenticate_user

        respond_to :json
        
    end
end