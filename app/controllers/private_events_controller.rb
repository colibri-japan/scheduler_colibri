class PrivateEventsController < ApplicationController
	before_action :set_private_event, only: [:show, :edit, :update, :destroy]
	before_action :set_planning
	before_action :set_corporation
	before_action :set_nurses, only: [:new, :edit]
	before_action :set_patients, only: [:new, :edit]


	def index
		if params[:nurse_id].present?
			@nurse = Nurse.find(params[:nurse_id])
			@private_events = @planning.private_events.where(nurse_id: params[:nurse_id])
		elsif params[:patient_id].present?
			@private_events = @planning.private_events.where(patient_id: params[:patient_id])
		else
			@private_events = @planning.private_events.all
		end

		if params[:start].present? && params[:end].present? 
			@private_events = @private_events.overlapping(params[:start]..params[:end])
		end

		patient_resource = params[:patient_resource].present?

		respond_to do |format|
			format.json {render json: @private_events.as_json(patient_resource: patient_resource)}
		end
	end

	def show
	end

	def new
	  @private_event = PrivateEvent.new
	end

	def edit
	end

	def create
		authorize @planning, :same_corporation_as_current_user?
	  @private_event = @planning.private_events.new(private_event_params)
		
	  respond_to do |format|
	    if @private_event.save
	      @activity = @private_event.create_activity :create, owner: current_user, planning_id: @planning.id, patient_id: @private_event.patient_id
	      format.js
	    else
	      format.js
	    end
	  end
	end
	
	def update
		authorize @planning, :same_corporation_as_current_user?
		
	  respond_to do |format|
	    if @private_event.update(private_event_params)
	      @activity = @private_event.create_activity :update, owner: current_user, planning_id: @planning.id, patient_id: @private_event.patient_id
				
	      format.js
	    else
	      format.js
	    end
	  end
	end
	
	def destroy
		authorize @planning, :same_corporation_as_current_user?

	  @activity = @private_event.create_activity :destroy, owner: current_user, planning_id: @planning.id, patient_id: @private_event.patient_id

	  @private_event.destroy
	  respond_to do |format|
	    format.html { redirect_to private_events_url, notice: 'private_event was successfully destroyed.' }
	    format.json { head :no_content }
	    format.js
	  end
	end

	private

	  def set_private_event
	    @private_event = PrivateEvent.find(params[:id])
	  end

	  def set_planning
	    @planning = Planning.find(params[:planning_id])
		end
		
		def set_nurses
			@nurses = @corporation.nurses.displayable.order_by_kana
		end
				
		def set_patients
			@patients = @corporation.cached_active_patients_ordered_by_kana
		end

	  def private_event_params
	    params.require(:private_event).permit(:title, :description, :starts_at, :ends_at, :nurse_id, :patient_id, :planning_id)
	  end
end
