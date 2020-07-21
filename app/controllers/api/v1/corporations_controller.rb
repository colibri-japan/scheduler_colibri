module Api
    module V1
        class CorporationsController < ActionController::API
            include Knock::Authenticable
            undef_method :current_user

            before_action :authenticate_user

            respond_to :json

            def index
                respond_with Corporation.all
            end
        end
    end
end