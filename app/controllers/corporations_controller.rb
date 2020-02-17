class CorporationsController < ApplicationController

    before_action :set_corporation, only: [:edit, :revenue_per_team_report]
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

    def revenue_per_team_report
		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day
        
        @revenue_per_team = @corporation.revenue_per_team(first_day..last_day)
        @salary_per_team = @corporation.salary_per_team(first_day..last_day)
        puts @salary_per_team
    end

    private

    def corporation_params
        params.require(:corporation).permit(:default_view, :default_individual_view, :default_master_view, :email, :business_start_hour, :business_end_hour, :custom_email_intro_text, :custom_email_outro_text, :default_first_day, :weekend_reminder_option, :reminder_email_hour, :include_description_in_nurse_mailer, :hour_based_payroll, :detailed_cancellation_options, :invoicing_bonus_ratio, :second_invoicing_bonus_ratio, :fax_number, :phone_number, :name, :identifier, :address, :credits_to_jpy_ratio, :availabilities_default_text, :edit_confirm_requested)
    end
end
