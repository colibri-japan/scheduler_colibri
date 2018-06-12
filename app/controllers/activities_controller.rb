class ActivitiesController < ApplicationController

	before_action :set_corporation

	def index
		@planning = Planning.find(params[:planning_id])
		employee_ids = @corporation.users.ids
		@activities = PublicActivity::Activity.where(planning_id: @planning.id).order("created_at desc").includes({trackable: :nurse}, {trackable: :patient}, :owner)
	end

	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

end
