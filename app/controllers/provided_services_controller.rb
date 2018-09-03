class ProvidedServicesController < ApplicationController
	before_action :set_provided_service

	def update
		@provided_service.total_wage ? @old_salary = @provided_service.total_wage : @old_salary=0

		respond_to do |format|
			if @provided_service.update(provided_service_params)
				format.js
			else
				format.js
			end
		end
	end

	def destroy
		@planning = Planning.find(@provided_service.planning_id)
		@nurse = Nurse.find(@provided_service.nurse_id)

		if @provided_service.delete
			redirect_to planning_nurse_payable_path(@planning, @nurse), notice: '実績が削除されました'
		end
	end


	private

	def set_provided_service
		@provided_service = ProvidedService.find(params[:id])
	end

	def provided_service_params
		params.require(:provided_service).permit(:hourly_wage, :service_counts)
	end


end