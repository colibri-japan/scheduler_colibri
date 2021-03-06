class SalaryLineItemsController < ApplicationController
	before_action :set_salary_line_item, except: [:create]
	before_action :set_nurse, except: [:destroy]


	def create
		@salary_line_item = SalaryLineItem.new(salary_line_item_params)
		@salary_line_item.nurse_id = params[:nurse_id]
		@salary_line_item.planning_id = current_user.corporation.planning.id

		if @salary_line_item.save
		  redirect_back fallback_location: current_user_home_path, notice: "新規手当が登録されました"
		end
	end

	def edit
	end

	def update
		respond_to do |format|
			if @salary_line_item.update(salary_line_item_params)
				format.js
				format.html {redirect_back fallback_location: current_user_home_path, notice: '実績がアップデートされました' }
			else
				format.html {redirect_back fallback_location: current_user_home_path, notice: '実績のアップデートが失敗しました' }
			end
		end
	end

	def destroy
		if @salary_line_item.delete
			redirect_back fallback_location: current_user_home_path, notice: '実績が削除されました'
		end
	end

	private

	def set_nurse
		@nurse = Nurse.find(params[:nurse_id]) if params[:nurse_id].present?
	end

	def set_salary_line_item
		@salary_line_item = SalaryLineItem.find(params[:id])
	end

	def salary_line_item_params
		params.require(:salary_line_item).permit(:title, :service_date, :total_wage, :invoiced_total, :skip_wage_credits_and_invoice_calculations)
	end
end