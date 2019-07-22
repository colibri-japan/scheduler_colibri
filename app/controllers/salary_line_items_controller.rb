class SalaryLineItemsController < ApplicationController
	before_action :set_salary_line_item, except: [:create, :salary_line_items_by_category_report]
	before_action :set_nurse, except: [:destroy, :salary_line_items_by_category_report]


	def create
		@salary_line_item = SalaryLineItem.new(salary_line_item_params)
		@salary_line_item.nurse_id = params[:nurse_id]
		@salary_line_item.planning_id = current_user.corporation.planning.id

		if @salary_line_item.save
		  redirect_back fallback_location: authenticated_root_path, notice: "新規手当がセーブされました"
		end
	end

	def edit
	end

	def update
		@salary_line_item.skip_callbacks_except_calculate_total_wage = true

		respond_to do |format|
			if @salary_line_item.update(salary_line_item_params)
				format.js
				format.html {redirect_back fallback_location: authenticated_root_path, notice: '実績がアップデートされました' }
			else
				format.html {redirect_back fallback_location: authenticated_root_path, notice: '実績のアップデートが失敗しました' }
			end
		end
	end

	def destroy
		if @salary_line_item.delete
			redirect_back fallback_location: authenticated_root_path, notice: '実績が削除されました'
		end
	end

	def salary_line_items_by_category_report
		set_corporation
		set_planning

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day

		@salary_line_items_grouped_by_category = SalaryLineItem.from_appointments.where(planning_id: @planning.id, cancelled: false, archived_at: nil).in_range(first_day..last_day).grouped_by_weighted_category(categories: params[:categories].try(:split,','))
		@available_categories = @corporation.services.where(nurse_id: nil).pluck(:category_1, :category_2).flatten.uniq
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