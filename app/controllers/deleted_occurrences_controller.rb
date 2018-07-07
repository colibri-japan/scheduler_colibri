class DeletedOccurrencesController < ApplicationController

	def create
		@recurring_appointment = RecurringAppointment.find(params[:recurring_appointment_id])
		@planning = Planning.find(@recurring_appointment.planning_id)
		@deleted_occurrence = @recurring_appointment.deleted_occurrences.new(deleted_occurrence_params)


		respond_to do |format|
			if @deleted_occurrence.save
				@activity = @recurring_appointment.create_activity :destroy, owner: current_user, planning_id: @planning.id
				format.js
			else
				format.js
			end
		end
	end

	private

	def deleted_occurrence_params
		params.require(:deleted_occurrence).permit(:deleted_day)
	end
		
end