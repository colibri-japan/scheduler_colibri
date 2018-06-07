class RecurringUnavailabilitiesController < ApplicationController
	before_action :set_recurring_unavailability, only: [:show, :edit, :update, :destroy]
	before_action :set_planning

	# GET /recurring_unavailabilities
	# GET /recurring_unavailabilities.json
	def index
	   if params[:nurse_id].present?
	     @recurring_unavailabilities = @planning.recurring_unavailabilities.where(nurse_id: params[:nurse_id])
	   elsif params[:patient_id].present?
	     @recurring_unavailabilities = @planning.recurring_unavailabilities.where(patient_id: params[:patient_id])
	   else
	    @recurring_unavailabilities = @planning.recurring_unavailabilities.all
	  end

	end

	# GET /recurring_unavailabilities/1
	# GET /recurring_unavailabilities/1.json
	def show
	end

	# GET /recurring_unavailabilities/new
	def new
	  @recurring_unavailability = RecurringUnavailability.new
	  @nurses = Nurse.all
	  @patients = Patient.all
	end

	# GET /recurring_unavailabilities/1/edit
	def edit
	  @nurses = Nurse.all
	  @patients = Patient.all
	end

	# POST /recurring_unavailabilities
	# POST /recurring_unavailabilities.json
	def create
	  @recurring_unavailability = @planning.recurring_unavailabilities.create(recurring_unavailability_params)

	  respond_to do |format|
	    if @recurring_unavailability.save
	      format.html { redirect_to @recurring_unavailability, notice: 'Recurring unavailability was successfully created.' }
	      format.js
	      format.json { render :show, status: :created, location: @recurring_unavailability }
	    else
	      format.html { render :new }
	      format.js
	      format.json { render json: @recurring_unavailability.errors, status: :unprocessable_entity }
	    end
	  end
	end

	# PATCH/PUT /recurring_unavailabilities/1
	# PATCH/PUT /recurring_unavailabilities/1.json
	def update
	  if params[:unavailability]
	    @recurring_unavailability.update(anchor: params[:unavailability][:start])
	  else
	    @recurring_unavailability.update(recurring_unavailability_params)
	  end
	end

	# DELETE /recurring_unavailabilities/1
	# DELETE /recurring_unavailabilities/1.json
	def destroy
	  @recurring_unavailability.destroy
	  respond_to do |format|
	    format.html { redirect_to recurring_unavailabilities_url, notice: 'Recurring unavailability was successfully destroyed.' }
	    format.json { head :no_content }
	    format.js
	  end
	end

	private
	  # Use callbacks to share common setup or constraints between actions.
	  def set_recurring_unavailability
	    @recurring_unavailability = RecurringUnavailability.find(params[:id])
	  end

	  def set_planning
	    @planning = Planning.find(params[:planning_id])
	  end

	  # Never trust parameters from the scary internet, only allow the white list through.
	  def recurring_unavailability_params
	    params.require(:recurring_unavailability).permit(:title, :anchor, :start_time, :end_time, :frequency, :nurse_id, :patient_id, :planning_id)
	  end
end
