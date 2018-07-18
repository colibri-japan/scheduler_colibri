class ActivitiesController < ApplicationController

	before_action :set_corporation

	def index
		@planning = Planning.find(params[:planning_id])
		employee_ids = @corporation.users.ids
		@nurses = @corporation.nurses.all
		@patients = @corporation.patients.all

		if params[:n].present? && @nurses.ids.include?(params[:n].to_i)
			@nurse = Nurse.find(params[:n])
		end

		if params[:pat].present? && @patients.ids.include?(params[:pat].to_i)
			@patient = Patient.find(params[:pat])
		end

		@activities = PublicActivity::Activity.where(planning_id: @planning.id).order("created_at desc").includes({trackable: :nurse}, {trackable: :patient}, :owner)
	end

	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

end
