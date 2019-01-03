class PagesController < ApplicationController
    before_action :authenticate_user!, except: :show

    layout 'pages'
    
    def show
        if valid_page?
            render template: "pages/#{params[:page]}"
        else
            raise ActionController::RoutingError.new('Not Foundù')
        end
    end
    
    private 

    def valid_page?
        File.exist?(Pathname.new(Rails.root + "app/views/pages/#{params[:page]}.html.erb"))
    end
end
