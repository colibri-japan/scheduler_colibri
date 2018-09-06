class ProvidedServicesController < ApplicationController
	before_action :set_provided_service, only: [:update, :destroy]

	def new
		@nurse = Nurse.find(params[:nurse_id])
		@provided_service = ProvidedService.new
		@planning = Planning.find(params[:planning_id].to_i)
	end

	def create
		@nurse = Nurse.find(params[:nurse_id])
		@provided_service = ProvidedService.new(provided_service_params)
		@planning = Planning.find(provided_service_params[:planning_id])

		@provided_service.provided = @provided_service.service_date < Time.current + 9.hours
		@provided_service.nurse_id = params[:nurse_id]

		puts 'hour based ?'
		puts @provided_service.hour_based_wage

		if @provided_service.save
		  redirect_to planning_nurse_payable_path(@planning, @nurse), notice: "新規手当がセーブされました"
		end

	end

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
		params.require(:provided_service).permit(:unit_cost, :service_counts, :title, :planning_id, :service_date, :hour_based_wage, :service_duration, :nurse_id)
	end


end