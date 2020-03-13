class CarePlansController < ApplicationController

    before_action :set_patient
    before_action :set_corporation
    before_action :set_care_managers, only: [:new, :edit]

    def new
        @care_plan = @patient.care_plans.build
        
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

        puts 'params, and params with converted dates'
        puts params
        puts params_with_converted_dates

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
        params.require(:care_plan).permit(:care_manager_id, :kaigo_level, :handicap_level, :kaigo_certification_date, :kaigo_certification_validity_start, :kaigo_certification_validity_end, :short_term_goals, :long_term_goals, :family_wishes, :patient_wishes,insurance_policy: [])
    end


end
