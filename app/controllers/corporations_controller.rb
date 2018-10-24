class CorporationsController < ApplicationController

    def update
        @corporation = Corporation.find(params[:id])

        if @corporation.update(corporation_params)
            redirect_back(fallback_location: root_path)
        end
    end

    private

    def corporation_params
        params.require(:corporation).permit(:default_view, :default_master_view, :email, :business_start_hour, :business_end_hour, :custom_email_intro_text, :custom_email_outro_text)
    end
end