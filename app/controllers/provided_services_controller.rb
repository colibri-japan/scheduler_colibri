class ProvidedServicesController < ApplicationController
	before_action :set_provided_service, only: [:update, :destroy, :edit, :destroy]
	before_action :set_nurse, except: [:destroy]
	before_action :set_planning, only: [:new, :edit]

	def new
		@provided_service = ProvidedService.new
	end

	def create
		@provided_service = ProvidedService.new(provided_service_params)
		@planning = Planning.find(provided_service_params[:planning_id])

		@provided_service.provided = @provided_service.service_date < Time.current + 9.hours
		@provided_service.nurse_id = params[:nurse_id]


		if @provided_service.save
		  redirect_to planning_nurse_payable_path(@planning, @nurse), notice: "新規手当がセーブされました"
		end

	end

	def edit
	end

	def update
		@planning = Planning.find(provided_service_params[:planning_id])

		respond_to do |format|
			if @provided_service.update(provided_service_params)
				format.html {redirect_to planning_nurse_payable_path(@planning, @nurse), notice: '実績がアップデートされました' }
			else
				format.html {redirect_to planning_nurse_payable_path(@planning, @nurse), notice: '実績のアップデートが失敗しました' }
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

	def set_planning
		@planning = Planning.find(params[:planning_id].to_i)
	end

	def set_nurse
		@nurse = Nurse.find(params[:nurse_id])
	end

	def set_provided_service
		@provided_service = ProvidedService.find(params[:id])
	end

	def provided_service_params
		params.require(:provided_service).permit(:unit_cost, :service_counts, :title, :planning_id, :service_date, :hour_based_wage, :service_duration, :nurse_id)
	end

	def self.add_service_date
		provided_services = ProvidedService.where(service_date: nil).where.not(appointment_id: nil)

		provided_services.each do |service|
			service.service_date = service.appointment.end
			service.appointment_start = service.appointment.start 
			service.appointment_end = service.appointment.end

			service.save
		end
	end


end