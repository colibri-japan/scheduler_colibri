class PlanningsController < ApplicationController

	before_action :set_corporation
	before_action :set_planning, only: [:show, :destroy, :master]

	def index
		@plannings = @corporation.plannings.all
	end

	def show
		authorize @planning, :is_employee?
		
		set_valid_range
		@activities = PublicActivity::Activity.where(planning_id: @planning.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)
	end

	def new
		@planning = Planning.new
	end

	def create
		@planning = Planning.new(planning_params)
		@planning.corporation_id = current_user.corporation_id

		respond_to do |format|
			if @planning.save
				format.html {redirect_to @planning, notice: 'Planning successfully created'}
				format.js
			else
				format.html { render :new }
				format.js
			end
		end
	end

	def destroy
	  authorize @planning, :is_employee?

	  @planning.destroy
	  respond_to do |format|
	    format.html { redirect_to plannings_url, notice: 'Planning was successfully destroyed.' }
	    format.json { head :no_content }
	    format.js
	  end
	end

	def master
		authorize @planning, :is_employee?

		set_valid_range
		@admin = current_user.admin.to_s
		puts "this is @admin"
		puts @admin
	end


	private

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def set_valid_range
		valid_month = @planning.business_month
		valid_year = @planning.business_year
		@start_valid = Date.new(valid_year, valid_month, 1).strftime("%Y-%m-%d")
		@end_valid = Date.new(valid_year, valid_month +1, 1).strftime("%Y-%m-%d")
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year)
	end

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

end
