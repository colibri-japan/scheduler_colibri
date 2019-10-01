class PlanningsController < ApplicationController
	before_action :set_corporation
	before_action :set_planning, except: [:recent_patients_report] 
	before_action :fetch_patients_grouped_by_kana, only: [:show, :master]
	before_action :fetch_nurses_grouped_by_team, only: [:show, :master]


	def show 
		authorize @planning, :same_corporation_as_current_user?
		set_main_nurse
		set_printing_option

		@nurses = @corporation.nurses.displayable.not_archived
	end
	
	def master 
		authorize @planning, :same_corporation_as_current_user?
		set_main_nurse
		set_printing_option

		@nurses = @corporation.nurses.displayable.not_archived
	end


	def new_master_to_schedule
		authorize current_user, :has_admin_access?
	end

	def master_to_schedule
		authorize @planning, :same_corporation_as_current_user?
		authorize current_user, :has_admin_access?

		CopyPlanningFromMasterWorker.perform_async(@planning.id, params[:month], params[:year])

		@planning.create_activity :reflect_all_master, owner: current_user, planning_id: @planning.id, parameters: {year: params[:year].to_i, month: params[:month].to_i}
	end

	def all_nurses_payable
		authorize current_user, :has_access_to_salary_line_items?
		
		@nurse = @corporation.nurses.displayable.order_by_kana.first 

		set_month_and_year_params
		fetch_nurses_grouped_by_team
		fetch_patients_grouped_by_kana

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0, 0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day	
	end

	def all_patients_payable
		authorize current_user, :has_access_to_salary_line_items?

		set_month_and_year_params
		fetch_nurses_grouped_by_team
		fetch_patients_grouped_by_kana

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day
		
		@care_manager_corporations = @corporation.care_manager_corporations
	end

	def monthly_general_report
		start_date = Date.new(params[:y].to_i, params[:m].to_i, 1).beginning_of_day
		end_date = Date.new(params[:y].to_i, params[:m].to_i, -1).end_of_day
		
		@service_hour_based_hash = @corporation.services.delivered_in_range(start_date..end_date).order(:title).pluck(:title, :hour_based_wage).uniq.to_h

		@appointments_count_and_sum_duration_by_nurse = @corporation.nurses.displayable.appointments_count_and_sum_duration_for(start_date..end_date)
		
		respond_to do |format|
			format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="従業員別実績.xlsx"'}
		end
	end

	def teams_report
		@appointment_counts_by_title_and_team = @corporation.appointments_count_by_title_and_team_in_range(params[:range_start], params[:range_end])

		@patients_count = @corporation.patients.active.count

		respond_to do |format|
			format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="チーム分け実績.xlsx"' }
		end
	end

	def recent_patients_report
		@recent_patients = @corporation.patients_with_contract_starting_after(Date.today - 60.days)

		respond_to do |format|
			format.xlsx {  response.headers['Content-Disposition'] = "attachment; filename=\"新規利用者#{Date.today}.xlsx\""  }
		end
	end


	private

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end

	def set_month_and_year_params
		@selected_year = params[:y].present? ? params[:y] : Date.today.year
    	@selected_month = params[:m].present? ? params[:m] : Date.today.month
	end

end
