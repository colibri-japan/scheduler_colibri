class PlanningsController < ApplicationController

	before_action :set_corporation

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
	  @planning = Planning.find(params[:id])
	  @planning.destroy
	  respond_to do |format|
	    format.html { redirect_to plannings_url, notice: 'Planning was successfully destroyed.' }
	    format.json { head :no_content }
	    format.js
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
