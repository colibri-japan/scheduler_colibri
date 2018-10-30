class CorporationsController < ApplicationController

    def update
        @corporation = Corporation.find(params[:id])

        if @corporation.update(corporation_params)
            redirect_back(fallback_location: root_path, notice: '情報がセーブされました。')
        end
    end

    private

    def corporation_params
        params.require(:corporation).permit(:default_view, :default_individual_view, :default_master_view, :email, :business_start_hour, :business_end_hour, :custom_email_intro_text, :custom_email_outro_text, :default_first_day)
    end
end
