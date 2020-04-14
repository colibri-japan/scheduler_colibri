class PagesController < ApplicationController
    before_action :authenticate_user!, except: :show
    before_action :set_home_page_cache_headers

    layout 'pages'
    
    def show
        if valid_page?
            render template: "pages/#{params[:page]}"
        else
            raise ActionController::RoutingError.new('Not Found')
        end
    end
    
    private 

    # wanted all the static pages to be cached, but root path cache conflicting with authenticated root
    #def set_home_page_cache_headers
    #    response.headers["Cache-Control"] = "public, max-age=2592000"
    #end

    def valid_page?
        File.exist?(Pathname.new(Rails.root + "app/views/pages/#{params[:page]}.html.erb"))
    end
end
