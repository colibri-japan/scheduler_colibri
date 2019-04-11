class ProvidedServicesController < ApplicationController
	before_action :set_provided_service, only: [:update, :destroy, :edit, :destroy, :toggle_verified, :toggle_second_verified]
	before_action :set_nurse, except: [:destroy, :toggle_verified, :toggle_second_verified]

	def new
		@provided_service = ProvidedService.new
		@services = current_user.corporation.services.without_nurse_id.order_by_title.all
	end

	def create
		@provided_service = ProvidedService.new(provided_service_params)
		@provided_service.nurse_id = params[:nurse_id]
		@provided_service.planning_id = current_user.corporation.planning.id

		if @provided_service.save
		  redirect_back fallback_location: authenticated_root_path, notice: "新規手当がセーブされました"
		end

	end

	def edit
	end

	def update
		@provided_service.skip_callbacks_except_calculate_total_wage = true

		respond_to do |format|
			if @provided_service.update(provided_service_params)
				format.html {redirect_back fallback_location: authenticated_root_path, notice: '実績がアップデートされました' }
			else
				format.html {redirect_back fallback_location: authenticated_root_path, notice: '実績のアップデートが失敗しました' }
			end
		end
	end

	def destroy
		if @provided_service.delete
			redirect_back fallback_location: authenticated_root_path, notice: '実績が削除されました'
		end
	end

	def toggle_verified
		@provided_service.toggle_verified!(current_user.id)
	end

	def toggle_second_verified
		@provided_service.toggle_second_verified!(current_user.id)
	end


	private

	def set_nurse
		@nurse = Nurse.find(params[:nurse_id])
	end

	def set_provided_service
		@provided_service = ProvidedService.find(params[:id])
	end

	def provided_service_params
		params.require(:provided_service).permit(:unit_cost, :service_counts, :title, :planning_id, :service_date, :hour_based_wage, :service_duration, :nurse_id, target_service_ids: [])
	end

	def self.add_service_date
		provided_services = ProvidedService.where(service_date: nil).where.not(appointment_id: nil)

		provided_services.each do |service|
			service.service_date = service.appointment.starts_at
			service.appointment_start = service.appointment.starts_at 
			service.appointment_end = service.appointment.ends_at

			service.save
		end
	end


end