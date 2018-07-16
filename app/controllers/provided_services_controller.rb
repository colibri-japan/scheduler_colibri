class ProvidedServicesController < ApplicationController

	def update
		@provided_service = ProvidedService.find(params[:id])
		@provided_service.total_wage ? @old_salary = @provided_service.total_wage : @old_salary=0

		respond_to do |format|
			if @provided_service.update(provided_service_params)
				format.js
			else
				format.js
			end
		end
	end

	private

	def provided_service_params
		params.require(:provided_service).permit(:hourly_wage, :service_counts)
	end


end