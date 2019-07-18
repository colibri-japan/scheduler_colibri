class CorporationsController < ApplicationController

    before_action :set_corporation, only: :edit
    before_action :set_planning, only: :edit 
    before_action :set_main_nurse, only: :edit

    def edit 
    end

    def update
        authorize current_user, :has_admin_access?
        
        @corporation = Corporation.find(params[:id])

        if @corporation.update(corporation_params)
            redirect_back(fallback_location: authenticated_root_path, notice: '設定がセーブされました')
        end
    end

    private

    def corporation_params
        params.require(:corporation).permit(:default_view, :default_individual_view, :default_master_view, :email, :business_start_hour, :business_end_hour, :custom_email_intro_text, :custom_email_outro_text, :default_first_day, :weekend_reminder_option, :reminder_email_hour, :include_description_in_nurse_mailer, :hour_based_payroll, :detailed_cancellation_options, :invoicing_bonus_ratio, :fax_number, :phone_number, :name, :identifier, :address, :credits_to_jpy_ratio, :availabilities_default_text)
    end
end
