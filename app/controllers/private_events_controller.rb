class PrivateEventsController < ApplicationController
	before_action :set_private_event, only: [:show, :edit, :update, :destroy]
	before_action :set_planning
	before_action :set_corporation
	before_action :set_nurses, only: [:new, :edit]
	before_action :set_patients, only: [:new, :edit]

	# GET /private_events
	# GET /private_events.json
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

	# GET /private_events/1
	# GET /private_events/1.json
	def show
	end

	# GET /private_events/new
	def new
	  @private_event = PrivateEvent.new
	end

	# GET /private_events/1/edit
	def edit
	end

	# POST /private_events
	# POST /private_events.json
	def create
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

	# PATCH/PUT /private_events/1
	# PATCH/PUT /private_events/1.json
	def update
	  respond_to do |format|
	    if @private_event.update(private_event_params)
	      @activity = @private_event.create_activity :update, owner: current_user, planning_id: @planning.id, patient_id: @private_event.patient_id

	      format.js
	    else
	      format.js
	    end
	  end
	end

	# DELETE /private_events/1
	# DELETE /private_events/1.json
	def destroy
	  @activity = @private_event.create_activity :destroy, owner: current_user, planning_id: @planning.id, patient_id: @private_event.patient_id

	  @private_event.destroy
	  respond_to do |format|
	    format.html { redirect_to private_events_url, notice: 'private_event was successfully destroyed.' }
	    format.json { head :no_content }
	    format.js
	  end
	end

	private
	  # Use callbacks to share common setup or constraints between actions.
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

	  # Never trust parameters from the scary internet, only allow the white list through.
	  def private_event_params
	    params.require(:private_event).permit(:title, :description, :starts_at, :ends_at, :nurse_id, :patient_id, :planning_id)
	  end
end
