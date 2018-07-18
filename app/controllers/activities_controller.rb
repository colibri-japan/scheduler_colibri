class ActivitiesController < ApplicationController

	before_action :set_corporation

	def index
		@planning = Planning.find(params[:planning_id])
		employee_ids = @corporation.users.ids
		@nurses = @corporation.nurses.all
		@patients = @corporation.patients.all
		@users = @corporation.users.all

		@activities = PublicActivity::Activity.where(planning_id: @planning.id).order("created_at desc").includes({trackable: :nurse}, {trackable: :patient}, :owner)

		if params[:n].present? && @nurses.ids.include?(params[:n].to_i)
			@nurse_id = params[:n]
			@activities = @activities.where(nurse_id: params[:n])
		end

		if params[:pat].present? && @patients.ids.include?(params[:pat].to_i)
			@patient_id = params[:pat]
			@activities = @activities.where(patient_id: params[:pat])
		end

		if params[:us].present? && @users.ids.include?(params[:us].to_i)
			@user_id = params[:us]
			@activities = @activities.where(owner_id: @user_id)
		end
	end

	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

end
