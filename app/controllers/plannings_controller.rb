class PlanningsController < ApplicationController

	def index
		@plannings = @corporation.plannings.all
	end

	def show
		@planning = Planning.find(params[:id])
	end

	def new
		@planning = Planning.new
	end

	def create
		@planning = Planning.new(planning_params)

		respond_to do |format|
			if @planning.save
				format.html {redirect_to @planning, notice: 'Schedule successfully created'}
				format.js
			else
				format.html { render :new }
				format.js
			end
		end
	end


	private

	def planning_params
		params.require(:planning).permit(:business_month, :business_year)
	end

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

end
