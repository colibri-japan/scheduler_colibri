class CarePlansController < ApplicationController

    before_action :set_patient
    before_action :set_corporation
    before_action :set_care_managers, only: [:new, :edit]

    def new
        last_care_plan = @patient.care_plans.order(created_at: :asc).last

        if last_care_plan.present?
            @care_plan = last_care_plan.dup

            reset_care_plan_fields!
        else
            @care_plan = @patient.care_plans.build

            @care_plan.creation_date = Date.today.in_time_zone('Tokyo')
        end
        
        respond_to do |format|
            format.js
            format.js.phone
        end
    end

    def create 
        params = care_plan_params
        params_with_converted_dates = convert_wareki_dates(params)
        @care_plan = @patient.care_plans.new(params_with_converted_dates)

        respond_to do |format|
            if @care_plan.save
                format.js
                format.js.phone
            end
        end
    end

    def edit
        @care_plan = CarePlan.find(params[:id])

        respond_to do |format|
            format.js
            format.js.phone
        end
    end

    def update 
        @care_plan = CarePlan.find(params[:id])

        params = care_plan_params
        params_with_converted_dates = convert_wareki_dates(params)

        respond_to do |format|
            if @care_plan.update(params_with_converted_dates)
                format.js 
                format.js.phone
            end
        end
    end

    def destroy
        @care_plan = CarePlan.find(params[:id])

        @care_plan.destroy
    end

    private

    def reset_care_plan_fields!
        @care_plan.creation_date = Date.today.in_time_zone('Tokyo')
        @care_plan.short_term_goals = nil 
        @care_plan.short_term_goals_start_date = nil 
        @care_plan.short_term_goals_due_date = nil 
    end

    def set_patient
        @patient = Patient.find(params[:patient_id])
    end

    def set_care_managers
        @care_managers = CareManager.where(care_manager_corporation_id: @corporation.care_manager_corporations.ids).includes(:care_manager_corporation)
    end

    def convert_wareki_dates(params)
        params[:kaigo_certification_date] = Date.parse_jp_date(params[:kaigo_certification_date]) rescue nil 
        params[:kaigo_certification_validity_start] = Date.parse_jp_date(params[:kaigo_certification_validity_start]) rescue nil 
        params[:kaigo_certification_validity_end] = Date.parse_jp_date(params[:kaigo_certification_validity_end]) rescue nil 
        params
    end

    def care_plan_params
        params.require(:care_plan).permit(:care_manager_id, :attending_nurse_id, :kaigo_level, :handicap_level, :kaigo_certification_date, :kaigo_certification_status, :kaigo_certification_validity_start, :kaigo_certification_validity_end, :short_term_goals, :short_term_goals_start_date,  :short_term_goals_due_date, :long_term_goals, :long_term_goals_start_date, :long_term_goals_due_date, :family_wishes, :creation_date, :patient_wishes, :meeting_date, insurance_policy: [])
    end


end
