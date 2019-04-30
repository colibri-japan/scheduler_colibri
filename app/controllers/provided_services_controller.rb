class ProvidedServicesController < ApplicationController
	before_action :set_provided_service, except: [:create]
	before_action :set_nurse, except: [:destroy, :toggle_verified, :toggle_second_verified, :new_cancellation_fee, :add_cancellation_fee]


	def create
		@provided_service = ProvidedService.new(provided_service_params)
		@provided_service.nurse_id = params[:nurse_id]
		@provided_service.planning_id = current_user.corporation.planning.id
		@provided_service.skip_wage_credits_and_invoice_calculations = true

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
				format.js
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

	def new_cancellation_fee
	end

	def add_cancellation_fee
		if @provided_service.update_columns(total_wage: cancellation_fee_params[:total_wage].to_i, updated_at: Time.current)
			redirect_back fallback_location: authenticated_root_path, notice: 'キャンセル手当が登録されました'
		else
			redirect_back fallback_location: authenticated_root_path, alert: 'キャンセル手当の登録が失敗しました'
		end
	end


	private

	def set_nurse
		@nurse = Nurse.find(params[:nurse_id]) if params[:nurse_id].present?
	end

	def set_provided_service
		@provided_service = ProvidedService.find(params[:id])
	end

	def provided_service_params
		params.require(:provided_service).permit(:title, :service_date, :total_wage, :invoiced_total, :skip_wage_credits_and_invoice_calculations)
	end

	def cancellation_fee_params
		params.require(:provided_service).permit(:total_wage)
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