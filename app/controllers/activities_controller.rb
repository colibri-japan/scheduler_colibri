class ActivitiesController < ApplicationController

	before_action :set_corporation

	def index
		employee_ids = @corporation.users.ids
		@activities = PublicActivity::Activity.order("created_at desc").where(owner_id: employee_ids)
	end

	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

end
