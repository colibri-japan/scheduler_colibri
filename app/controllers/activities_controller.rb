class ActivitiesController < ApplicationController

	before_action :set_corporation

	def index
		@planning = Planning.find(params[:planning_id])
		authorize @planning, :same_corporation_as_current_user?
		authorize current_user, :has_admin_access?

		employee_ids = @corporation.users.ids
		@nurses = @corporation.nurses.order_by_kana
		@patients = @corporation.cached_all_patients_ordered_by_kana
		@users = @corporation.users.all
		@main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first

		appointment_activities = PublicActivity::Activity.where(planning_id: @planning.id, trackable_type: ['Appointment', 'RecurringAppointment']).limit(25).order("created_at desc").includes({trackable: [:nurse, :patient]}, :owner)
		other_activities = PublicActivity::Activity.where(planning_id: @planning.id).where.not(trackable_type: ['Appointment', 'RecurringAppointment']).limit(10).order("created_at desc").includes(:owner)
		@activities = (appointment_activities + other_activities).sort {|a| a.created_at}

		if params[:n].present? && @nurses.ids.include?(params[:n].to_i)
			@nurse_id = params[:n]
			@activities = @activities.where('nurse_id = ?', params[:n])
		end

		if params[:pat].present? && @patients.ids.include?(params[:pat].to_i)
			@patient_id = params[:pat]
			@activities = @activities.where('patient_id = ?', params[:pat])
		end

		if params[:us].present? && @users.ids.include?(params[:us].to_i)
			@user_id = params[:us]
			@activities = @activities.where('owner_id = ?', @user_id)
		end
	end

	def activities_widget
		set_planning

    	@activities = PublicActivity::Activity.where(planning_id: @planning.id, created_at: current_user.last_sign_in_at..current_user.current_sign_in_at).includes(:owner).limit(10)

		@unseen_activity_count = @activities.count
    	if @unseen_activity_count == 0
    	  @activities = PublicActivity::Activity.where(planning_id: @planning.id).includes(:owner).last(5)
		end
		
		respond_to do |format|
			format.js
		end
	end

	private


end
